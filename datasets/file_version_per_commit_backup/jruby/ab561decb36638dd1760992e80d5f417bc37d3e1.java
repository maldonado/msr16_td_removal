/***** BEGIN LICENSE BLOCK *****
 * Version: CPL 1.0/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Common Public
 * License Version 1.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.eclipse.org/legal/cpl-v10.html
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * Copyright (C) 2001 Chad Fowler <chadfowler@chadfowler.com>
 * Copyright (C) 2001 Alan Moore <alan_moore@gmx.net>
 * Copyright (C) 2001-2002 Benoit Cerrina <b.cerrina@wanadoo.fr>
 * Copyright (C) 2001-2004 Jan Arne Petersen <jpetersen@uni-bonn.de>
 * Copyright (C) 2002-2004 Anders Bengtsson <ndrsbngtssn@yahoo.se>
 * Copyright (C) 2004 Thomas E Enebo <enebo@acm.org>
 * Copyright (C) 2004 Charles O Nutter <headius@headius.com>
 * Copyright (C) 2004 Stefan Matthias Aust <sma@3plus4.de>
 * 
 * Alternatively, the contents of this file may be used under the terms of
 * either of the GNU General Public License Version 2 or later (the "GPL"),
 * or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the CPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the CPL, the GPL or the LGPL.
 ***** END LICENSE BLOCK *****/
package org.jruby;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.io.Reader;
import java.io.StringReader;
import java.util.Hashtable;
import java.util.List;
import java.util.Random;
import java.util.Stack;

import org.jruby.ast.Node;
import org.jruby.common.RubyWarnings;
import org.jruby.evaluator.EvaluateVisitor;
import org.jruby.exceptions.ArgumentError;
import org.jruby.exceptions.BreakJump;
import org.jruby.exceptions.EOFError;
import org.jruby.exceptions.ErrnoError;
import org.jruby.exceptions.IOError;
import org.jruby.exceptions.IndexError;
import org.jruby.exceptions.RetryJump;
import org.jruby.exceptions.ReturnJump;
import org.jruby.exceptions.SecurityError;
import org.jruby.exceptions.SystemCallError;
import org.jruby.exceptions.TypeError;
import org.jruby.internal.runtime.GlobalVariables;
import org.jruby.internal.runtime.ThreadService;
import org.jruby.internal.runtime.ValueAccessor;
import org.jruby.internal.runtime.methods.IterateMethod;
import org.jruby.javasupport.Java;
import org.jruby.javasupport.JavaSupport;
import org.jruby.lexer.yacc.SourcePosition;
import org.jruby.parser.Parser;
import org.jruby.runtime.Block;
import org.jruby.runtime.BlockStack;
import org.jruby.runtime.CacheMap;
import org.jruby.runtime.CallbackFactory;
import org.jruby.runtime.Frame;
import org.jruby.runtime.FrameStack;
import org.jruby.runtime.GlobalVariable;
import org.jruby.runtime.IAccessor;
import org.jruby.runtime.Iter;
import org.jruby.runtime.LastCallStatus;
import org.jruby.runtime.ObjectSpace;
import org.jruby.runtime.Scope;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.Visibility;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.builtin.meta.ArrayMetaClass;
import org.jruby.runtime.builtin.meta.FileMetaClass;
import org.jruby.runtime.builtin.meta.FixnumMetaClass;
import org.jruby.runtime.builtin.meta.HashMetaClass;
import org.jruby.runtime.builtin.meta.IOMetaClass;
import org.jruby.runtime.builtin.meta.IntegerMetaClass;
import org.jruby.runtime.builtin.meta.ModuleMetaClass;
import org.jruby.runtime.builtin.meta.NumericMetaClass;
import org.jruby.runtime.builtin.meta.ObjectMetaClass;
import org.jruby.runtime.builtin.meta.ProcMetaClass;
import org.jruby.runtime.builtin.meta.StringMetaClass;
import org.jruby.runtime.builtin.meta.SymbolMetaClass;
import org.jruby.runtime.callback.Callback;
import org.jruby.runtime.load.IAutoloadMethod;
import org.jruby.runtime.load.ILoadService;
import org.jruby.runtime.load.LoadServiceFactory;
import org.jruby.util.BuiltinScript;

/**
 * The jruby runtime.
 *
 * @author  jpetersen
 * @version $Revision$
 * @since   0.1
 */
public final class Ruby {
	private CacheMap cacheMap = new CacheMap();
    private ThreadService threadService = new ThreadService(this);

    public int stackTraces = 0;

    public ObjectSpace objectSpace = new ObjectSpace();

    public final RubyFixnum[] fixnumCache = new RubyFixnum[256];
    public final RubySymbol.SymbolTable symbolTable = new RubySymbol.SymbolTable();
    public Hashtable ioHandlers = new Hashtable();
    public long randomSeed = 0;
    public long randomSeedSequence = 0;
    public Random random = new Random();

    private RubyProc traceFunction;
    private boolean isWithinTrace = false;

    /** safe-level:
    		0 - strings from streams/environment/ARGV are tainted (default)
    		1 - no dangerous operation by tainted value
    		2 - process/file operations prohibited
    		3 - all genetated objects are tainted
    		4 - no global (non-tainted) variable modification/no direct output
    */
    private int safeLevel = 0;

    // Default classes/objects
    private IRubyObject nilObject;
    private RubyBoolean trueObject;
    private RubyBoolean falseObject;
    private RubyClass objectClass;
    private RubyClass systemCallError = null;
    private RubyModule errnoModule = null;
    private IRubyObject topSelf;
    private IRubyObject verbose;

    // Java support
    private JavaSupport javaSupport;

    private Parser parser = new Parser(this);

    private LastCallStatus lastCallStatus = new LastCallStatus(this);

    private ILoadService loadService = LoadServiceFactory.createLoadService(this);
    private GlobalVariables globalVariables = new GlobalVariables(this);
    private RubyWarnings warnings = new RubyWarnings(this);

    // Contains a list of all blocks (as Procs) that should be called when
    // the runtime environment exits.
    private Stack atExitBlocks = new Stack();

    /**
     * Create and initialize a new jruby Runtime.
     */
    private Ruby() {
        nilObject = new RubyNil(this);
        trueObject = new RubyBoolean(this, true);
        falseObject = new RubyBoolean(this, false);

        verbose = falseObject;
        
        javaSupport = new JavaSupport(this);
    }
    
    /**
     * Retrieve mappings of cached methods to where they have been cached.  When a cached
     * method needs to be invalidated this map can be used to remove all places it has been
     * cached.
     * 
     * @return the mappings of where cached methods have been stored
     */
	public CacheMap getCacheMap() {
		return cacheMap;
	}

    /**
     * Returns a default instance of the JRuby runtime.
     *
     * @return the JRuby runtime
     */
    public static Ruby getDefaultInstance() {
        Ruby runtime = new Ruby();
        runtime.init();
        return runtime;
    }

    /**
     * Evaluates a script and returns a RubyObject.
     */
    public IRubyObject evalScript(String script) {
        return eval(parse(script, "<script>"));
    }

    public IRubyObject eval(Node node) {
        try {
	        return EvaluateVisitor.createVisitor(getTopSelf()).eval(node);
        } catch (ReturnJump e) {
            return e.getReturnValue();
		}
    }

    public RubyClass getObject() {
    	return objectClass;
    }

    /** Returns the "true" instance from the instance pool.
     * @return The "true" instance.
     */
    public RubyBoolean getTrue() {
        return trueObject;
    }

    /** Returns the "false" instance from the instance pool.
     * @return The "false" instance.
     */
    public RubyBoolean getFalse() {
        return falseObject;
    }

    /** Returns the "nil" singleton instance.
     * @return "nil"
     */
    public IRubyObject getNil() {
        return nilObject;
    }

    public RubyModule getModule(String name) {
        return (RubyModule) objectClass.getConstant(name, false);
    }

    /** Returns a class from the instance pool.
     *
     * @param name The name of the class.
     * @return The class.
     */
    public RubyClass getClass(String name) {
        try {
            return objectClass.getClass(name);
        } catch (ClassCastException e) {
            throw newTypeError(name + " is not a Class");
        }
    }

    /** Define a new class with name 'name' and super class 'superClass'.
     *
     * MRI: rb_define_class / rb_define_class_id
     *
     */
    public RubyClass defineClass(String name, RubyClass superClass) {
        return defineClassUnder(name, superClass, objectClass);
    }
    
    public RubyClass defineClassUnder(String name, RubyClass superClass, RubyModule parentModule) {
        if (superClass == null) {
            superClass = objectClass;
        }

        return superClass.newSubClass(name, parentModule);
    }
    
    /** rb_define_module / rb_define_module_id
     *
     */
    public RubyModule defineModule(String name) {
        return defineModuleUnder(name, objectClass);
    }
    
    public RubyModule defineModuleUnder(String name, RubyModule parentModule) {
        RubyModule newModule = RubyModule.newModule(this, name, parentModule);

        parentModule.setConstant(name, newModule);
        
        return newModule;
    }
    
    /**
     * In the current context, get the named module. If it doesn't exist a
     * new module is created.
     */
    public RubyModule getOrCreateModule(String name) {
        RubyModule module = (RubyModule) getRubyClass().getConstant(name, false);
        
        if (module == null) {
            module = (RubyModule) getRubyClass().setConstant(name, 
            		defineModule(name)); 
        } else if (getSafeLevel() >= 4) {
        	throw new SecurityError(this, "Extending module prohibited.");
        }

        if (getWrapper() != null) {
            module.getSingletonClass().includeModule(getWrapper());
            module.includeModule(getWrapper());
        }
        return module;
    }
    

    /** Getter for property securityLevel.
     * @return Value of property securityLevel.
     */
    public int getSafeLevel() {
        return this.safeLevel;
    }

    /** Setter for property securityLevel.
     * @param safeLevel New value of property securityLevel.
     */
    public void setSafeLevel(int safeLevel) {
        this.safeLevel = safeLevel;
    }

    public void secure(int level) {
        if (level <= safeLevel) {
            throw new SecurityError(this, "Insecure operation '" + getCurrentFrame().getLastFunc() + "' at level " + safeLevel);
        }
    }

    /** rb_define_global_const
     *
     */
    public void defineGlobalConstant(String name, IRubyObject value) {
        objectClass.defineConstant(name, value);
    }

    public IRubyObject getTopConstant(String name) {
        IRubyObject constant = getModule(name);
        if (constant == null) {
            constant = getLoadService().autoload(name);
        }
        return constant;
    }

    public boolean isClassDefined(String name) {
        return getModule(name) != null;
    }

    public IRubyObject yield(IRubyObject value) {
        return yield(value, null, null, false);
    }

    public IRubyObject yield(IRubyObject value, IRubyObject self, RubyModule klass, boolean checkArguments) {
        return getCurrentContext().yield(value, self, klass, false, checkArguments);
    }

    /** Getter for property rubyTopSelf.
     * @return Value of property rubyTopSelf.
     */
    public IRubyObject getTopSelf() {
        return topSelf;
    }

    /** rb_iterate
     *
     */
    public IRubyObject iterate(Callback iterateMethod, IRubyObject data1, Callback blockMethod, IRubyObject data2) {
        getIterStack().push(Iter.ITER_PRE);
        getBlockStack().push(Block.createBlock(null, new IterateMethod(blockMethod, data2), getTopSelf()));

        try {
            while (true) {
                try {
                    return iterateMethod.execute(data1, IRubyObject.NULL_ARRAY);
                } catch (BreakJump bExcptn) {
                    IRubyObject breakValue = bExcptn.getBreakValue();
                    
                    return breakValue == null ? getNil() : breakValue;
                } catch (ReturnJump rExcptn) {
                    return rExcptn.getReturnValue();
                } catch (RetryJump rExcptn) {
                    // Execute iterateMethod again.
                }
            }
        } finally {
            getIterStack().pop();
            getBlockStack().pop();
        }
    }

    /** ruby_init
     *
     */
    private void init() {
        getIterStack().push(Iter.ITER_NOT);
        Frame frame = (Frame) getFrameStack().push(new Frame(getCurrentContext()));
        getCurrentContext().getScopeStack().push(new Scope(this));

        setCurrentVisibility(Visibility.PRIVATE);

        initCoreClasses();

        RubyGlobal.createGlobals(this);

        topSelf = TopSelfFactory.createTopSelf(this);

        getCurrentContext().setRubyClass(objectClass);
        frame.setSelf(topSelf);

        initBuiltinClasses();
    }
    
    private void initCoreClasses() {
        objectClass = new ObjectMetaClass(this);
        objectClass.setConstant("Object", objectClass);
        RubyClass moduleClass = new ModuleMetaClass(this, objectClass);
        objectClass.setConstant("Module", moduleClass);
        RubyClass classClass = new RubyClass(this, null /* Would be Class if it could */, moduleClass, null, "Class");
        objectClass.setConstant("Class", classClass);

        RubyClass metaClass = objectClass.makeMetaClass(classClass, getCurrentContext().getRubyClass());
        metaClass = moduleClass.makeMetaClass(metaClass, getCurrentContext().getRubyClass());
        metaClass = classClass.makeMetaClass(metaClass, getCurrentContext().getRubyClass());

        ((ObjectMetaClass) moduleClass).initializeBootstrapClass();
        
        objectClass.includeModule(RubyKernel.createKernelModule(this));

        RubyClass.createClassClass(classClass);

        RubyNil.createNilClass(this);

        // We cannot define this constant until nil itself was made
        objectClass.defineConstant("NIL", getNil());
        
        // Pre-create the core classes we know we will get referenced by starting up the runtime.
        RubyBoolean.createFalseClass(this);
        RubyBoolean.createTrueClass(this);
        RubyComparable.createComparable(this);
        defineModule("Enumerable"); // Impl: src/builtin/enumerable.rb
        new StringMetaClass(this);
        new SymbolMetaClass(this);
        RubyThreadGroup.createThreadGroupClass(this);
        RubyThread.createThreadClass(this);
        RubyException.createExceptionClass(this);
        new NumericMetaClass(this);
        new IntegerMetaClass(this);        
        new FixnumMetaClass(this);
        new HashMetaClass(this);
        new IOMetaClass(this);
        new ArrayMetaClass(this);
        Java.createJavaModule(this);
        RubyStruct.createStructClass(this);
        RubyFloat.createFloatClass(this);
        RubyBignum.createBignumClass(this);
        RubyMath.createMathModule(this); // depends on all numeric types
        RubyRegexp.createRegexpClass(this);
        RubyRange.createRangeClass(this);
        RubyObjectSpace.createObjectSpaceModule(this);
        RubyGC.createGCModule(this);
        new ProcMetaClass(this);
        RubyMethod.createMethodClass(this);
        RubyMatchData.createMatchDataClass(this);
        RubyMarshal.createMarshalModule(this);
        RubyDir.createDirClass(this);
        RubyFileTest.createFileTestModule(this);
        new FileMetaClass(this); // depends on IO, FileTest
        RubyPrecision.createPrecisionModule(this);
        RubyProcess.createProcessModule(this);
        RubyTime.createTimeClass(this);
        RubyUnboundMethod.defineUnboundMethodClass(this);
        RubyClass exceptionClass = getClass("Exception");
        RubyClass standardError = defineClass("StandardError", exceptionClass);
        RubyClass runtimeError = defineClass("RuntimeError", standardError);
        RubyClass ioError = defineClass("IOError", standardError);
        RubyClass scriptError = defineClass("ScriptError", exceptionClass);
        RubyClass nameError = defineClass("NameError", scriptError);
        defineClass("SystemExit", exceptionClass);
        defineClass("Fatal", exceptionClass);
        defineClass("Interrupt", exceptionClass);
        defineClass("SignalException", exceptionClass);
        defineClass("TypeError", standardError);
        defineClass("ArgumentError", standardError);
        defineClass("IndexError", standardError);
        defineClass("RangeError", standardError);
        defineClass("SyntaxError", scriptError);
        defineClass("LoadError", scriptError);
        defineClass("NotImplementedError", scriptError);
        defineClass("NoMethodError", nameError);
        defineClass("SecurityError", standardError);
        defineClass("NoMemError", exceptionClass);
        defineClass("RegexpError", standardError);
        defineClass("EOFError", ioError);
        defineClass("LocalJumpError", standardError);
        defineClass("ThreadError", standardError);
        defineClass("SystemStackError", exceptionClass);
        NativeException.createClass(this, runtimeError);
        systemCallError = defineClass("SystemCallError", standardError);
        errnoModule = defineModule("Errno");
        
        initErrnoErrors();

        getLoadService().addAutoload("UnboundMethod", new IAutoloadMethod() {
            public IRubyObject load(Ruby ruby, String name) {
                return RubyUnboundMethod.defineUnboundMethodClass(ruby);
            }
        });
    }

    private void initBuiltinClasses() {
    	try {
	        new BuiltinScript("FalseClass").load(this);
	        new BuiltinScript("TrueClass").load(this);
	        new BuiltinScript("Enumerable").load(this);
    	} catch (IOException e) {
    		throw new Error("builtin scripts are missing", e);
    	}
    }
    
    /**
     * Create module Errno's Variables.  We have this method since Errno does not have it's 
     * own java class.
     */
    private void initErrnoErrors() {
        createSysErr(IErrno.ENOTEMPTY, "ENOTEMPTY");   
        createSysErr(IErrno.ERANGE, "ERANGE");      
        createSysErr(IErrno.ESPIPE, "ESPIPE");      
        createSysErr(IErrno.ENFILE, "ENFILE");      
        createSysErr(IErrno.EXDEV, "EXDEV");       
        createSysErr(IErrno.ENOMEM, "ENOMEM");      
        createSysErr(IErrno.E2BIG, "E2BIG");       
        createSysErr(IErrno.ENOENT, "ENOENT");      
        createSysErr(IErrno.ENOSYS, "ENOSYS");      
        createSysErr(IErrno.EDOM, "EDOM");        
        createSysErr(IErrno.ENOSPC, "ENOSPC");      
        createSysErr(IErrno.EINVAL, "EINVAL");      
        createSysErr(IErrno.EEXIST, "EEXIST");      
        createSysErr(IErrno.EAGAIN, "EAGAIN");      
        createSysErr(IErrno.ENXIO, "ENXIO");       
        createSysErr(IErrno.EILSEQ, "EILSEQ");      
        createSysErr(IErrno.ENOLCK, "ENOLCK");      
        createSysErr(IErrno.EPIPE, "EPIPE");       
        createSysErr(IErrno.EFBIG, "EFBIG");       
        createSysErr(IErrno.EISDIR, "EISDIR");      
        createSysErr(IErrno.EBUSY, "EBUSY");       
        createSysErr(IErrno.ECHILD, "ECHILD");      
        createSysErr(IErrno.EIO, "EIO");         
        createSysErr(IErrno.EPERM, "EPERM");       
        createSysErr(IErrno.EDEADLOCK, "EDEADLOCK");   
        createSysErr(IErrno.ENAMETOOLONG, "ENAMETOOLONG");
        createSysErr(IErrno.EMLINK, "EMLINK");      
        createSysErr(IErrno.ENOTTY, "ENOTTY");      
        createSysErr(IErrno.ENOTDIR, "ENOTDIR");     
        createSysErr(IErrno.EFAULT, "EFAULT");      
        createSysErr(IErrno.EBADF, "EBADF");       
        createSysErr(IErrno.EINTR, "EINTR");       
        createSysErr(IErrno.EWOULDBLOCK, "EWOULDBLOCK"); 
        createSysErr(IErrno.EDEADLK, "EDEADLK");     
        createSysErr(IErrno.EROFS, "EROFS");       
        createSysErr(IErrno.EMFILE, "EMFILE");      
        createSysErr(IErrno.ENODEV, "ENODEV");      
        createSysErr(IErrno.EACCES, "EACCES");      
        createSysErr(IErrno.ENOEXEC, "ENOEXEC");             
        createSysErr(IErrno.ESRCH, "ESRCH");       
        createSysErr(IErrno.ECONNREFUSED, "ECONNREFUSED");
    }

    /**
     * Creates a system error.
     * @param i the error code (will probably use a java exception instead)
     * @param name of the error to define.
     **/
    private void createSysErr(int i, String name) {
        errnoModule.defineClassUnder(name, systemCallError).defineConstant("Errno", newFixnum(i));
    }
    
	/**
	 * Get top-most (current) scope (local vars) in the current thread context.
	 */
	public Scope getCurrentScope() {
		return getCurrentContext().currentScope();
	}

    /** Getter for property sourceFile.
     * @return Value of property sourceFile.
     */
    public String getSourceFile() {
        return getPosition().getFile();
    }

    /** Getter for property sourceLine.
     * @return Value of property sourceLine.
     */
    public int getSourceLine() {
        return getPosition().getLine();
    }

    /** Getter for property isVerbose.
     * @return Value of property isVerbose.
     */
    public IRubyObject getVerbose() {
        return verbose;
    }

    public boolean isBlockGiven() {
        return getCurrentFrame().isBlockGiven();
    }

    public boolean isFBlockGiven() {
        Frame previous = getFrameStack().getPrevious();
        if (previous == null) {
            return false;
        }
        return previous.isBlockGiven();
    }

    /** Setter for property isVerbose.
     * @param verbose New value of property isVerbose.
     */
    public void setVerbose(IRubyObject verbose) {
        this.verbose = verbose;
    }

    public RubyModule getRubyClass() {
        return getCurrentContext().getRubyClass();
    }

    public FrameStack getFrameStack() {
        return getCurrentContext().getFrameStack();
    }

    public Frame getCurrentFrame() {
        return getCurrentContext().getCurrentFrame();
    }

    public JavaSupport getJavaSupport() {
        return javaSupport;
    }

    public Stack getIterStack() {
        return getCurrentContext().getIterStack();
    }

    public BlockStack getBlockStack() {
        return getCurrentContext().getBlockStack();
    }

    public Visibility getCurrentVisibility() {
        return getCurrentScope().getVisibility();
    }

    public void setCurrentVisibility(Visibility visibility) {
        getCurrentScope().setVisibility(visibility);
    }

    /** Getter for property wrapper.
     * @return Value of property wrapper.
     */
    public RubyModule getWrapper() {
        return getCurrentContext().getWrapper();
    }

    /** Defines a global variable
     */
    public void defineVariable(final GlobalVariable variable) {
        globalVariables.define(variable.name(), new IAccessor() {
            public IRubyObject getValue() {
                return variable.get();
            }

            public IRubyObject setValue(IRubyObject newValue) {
                return variable.set(newValue);
            }
        });
    }

    /** defines a readonly global variable
     *
     */
    public void defineReadonlyVariable(String name, IRubyObject value) {
        globalVariables.defineReadonly(name, new ValueAccessor(value));
    }

    public Node parse(Reader content, String file) {
        return parser.parse(file, content);
    }

    public Node parse(String content, String file) {
        return parser.parse(file, content);
    }

    public IRubyObject getLastline() {
        return getCurrentScope().getLastLine();
    }

    public void setLastline(IRubyObject value) {
        getCurrentScope().setLastLine(value);
    }

    public IRubyObject getBackref() {
        return getCurrentScope().getBackref();
    }

    public Parser getParser() {
        return parser;
    }

    public ThreadService getThreadService() {
        return threadService;
    }

    public ThreadContext getCurrentContext() {
        return threadService.getCurrentContext();
    }

    public SourcePosition getPosition() {
        return getCurrentContext().getPosition();
    }

    public void setPosition(String file, int line) {
        getCurrentContext().setPosition(file, line);
    }

    public void setPosition(SourcePosition position) {
        getCurrentContext().setPosition(position);
    }

    /**
     * Returns the lastCallStatus.
     * @return LastCallStatus
     */
    public LastCallStatus getLastCallStatus() {
        return lastCallStatus;
    }

    /**
     * Returns the loadService.
     * @return ILoadService
     */
    public ILoadService getLoadService() {
        return loadService;
    }

    public RubyWarnings getWarnings() {
        return warnings;
    }

    public PrintStream getErrorStream() {
        return new PrintStream(((RubyIO) getGlobalVariables().get("$stderr")).getOutStream());
    }

    public InputStream getInputStream() {
        return ((RubyIO) getGlobalVariables().get("$stdin")).getInStream();
    }

    public PrintStream getOutputStream() {
        return new PrintStream(((RubyIO) getGlobalVariables().get("$stdout")).getOutStream());
    }

    public RubyModule getClassFromPath(String path) {
        if (path.charAt(0) == '#') {
            throw newArgumentError("can't retrieve anonymous class " + path);
        }
        IRubyObject type = evalScript(path);
        if (!(type instanceof RubyModule)) {
            throw newTypeError("class path " + path + " does not point class");
        }
        return (RubyModule) type;
    }
    
    private static final int TRACE_HEAD = 8;
    private static final int TRACE_TAIL = 5;
    private static final int TRACE_MAX = TRACE_HEAD + TRACE_TAIL + 5;
    /** Prints an error with backtrace to the error stream.
     *
     * MRI: eval.c - error_print()
     *
     */
    public void printError(RubyException excp) {
        if (excp == null || excp.isNil()) {
            return;
        }

        RubyArray backtrace = (RubyArray) excp.callMethod("backtrace");

        if (backtrace.isNil()) {
            if (getSourceFile() != null) {
                getErrorStream().print(getPosition());
            } else {
                getErrorStream().print(getSourceLine());
            }
        } else if (backtrace.getLength() == 0) {
            printErrorPos();
        } else {
            IRubyObject mesg = backtrace.first(IRubyObject.NULL_ARRAY);

            if (mesg.isNil()) {
                printErrorPos();
            } else {
                getErrorStream().print(mesg);
            }
        }

        RubyClass type = excp.getMetaClass();
        String info = excp.toString();

        if (type == getClass("RuntimeError") && (info == null || info.length() == 0)) {
            getErrorStream().print(": unhandled exception\n");
        } else {
            String path = type.getName();

            if (info.length() == 0) {
                getErrorStream().print(": " + path + '\n');
            } else {
                if (path.startsWith("#")) {
                    path = null;
                }

                String tail = null;
                if (info.indexOf("\n") != -1) {
                    tail = info.substring(info.indexOf("\n") + 1);
                    info = info.substring(0, info.indexOf("\n"));
                }

                getErrorStream().print(": " + info);

                if (path != null) {
                    getErrorStream().print(" (" + path + ")\n");
                }

                if (tail != null) {
                    getErrorStream().print(tail + '\n');
                }
            }
        }

        if (!backtrace.isNil()) {
            IRubyObject[] elements = backtrace.toJavaArray();

            for (int i = 1; i < elements.length; i++) {
                if (elements[i] instanceof RubyString) {
                    getErrorStream().print("\tfrom " + elements[i] + '\n');
                }

                if (i == TRACE_HEAD && elements.length > TRACE_MAX) {
                    getErrorStream().print("\t ... " + (elements.length - TRACE_HEAD - TRACE_TAIL) + "levels...\n");
                    i = elements.length - TRACE_TAIL;
                }
            }
        }
    }

    private void printErrorPos() {
        if (getSourceFile() != null) {
            if (getCurrentFrame().getLastFunc() != null) {
                getErrorStream().print(getPosition());
                getErrorStream().print(":in '" + getCurrentFrame().getLastFunc() + '\'');
            } else if (getSourceLine() != 0) {
                getErrorStream().print(getPosition());
            } else {
                getErrorStream().print(getSourceFile());
            }
        }
    }

    /** This method compiles and interprets a Ruby script.
     *
     *  It can be used if you want to use JRuby as a Macro language.
     *
     */
    public void loadScript(RubyString scriptName, RubyString source, boolean wrap) {
        loadScript(scriptName.getValue(), new StringReader(source.getValue()), wrap);
    }

    public void loadScript(String scriptName, Reader source, boolean wrap) {
        IRubyObject self = getTopSelf();

        ThreadContext context = getCurrentContext();

        context.pushDynamicVars();

        RubyModule wrapper = context.getWrapper();
		RubyModule oldParent;

        if (!wrap) {
            secure(4); /* should alter global state */
            oldParent = context.setRubyClass(objectClass);
            context.setWrapper(null);
        } else {
            /* load in anonymous module as toplevel */
            context.setWrapper(RubyModule.newModule(this, null));
            oldParent = context.setRubyClass(context.getWrapper());
            self = getTopSelf().rbClone();
            self.extendObject(context.getRubyClass());
        }

        context.getFrameStack().push(new Frame(context, self, IRubyObject.NULL_ARRAY, null, null));
        context.getScopeStack().push(new Scope(this));

        /* default visibility is private at loading toplevel */
        setCurrentVisibility(Visibility.PRIVATE);

        try {
        	Node node = parse(source, scriptName);
            self.eval(node);
        } catch (ReturnJump e) {
			// Make sure this does not bubble out to java caller.
        } finally {
            context.getScopeStack().pop();
            context.getFrameStack().pop();
            context.setRubyClass(oldParent);
            context.popDynamicVars();
            context.setWrapper(wrapper);
        }
    }

    public void loadNode(String scriptName, Node node, boolean wrap) {
        IRubyObject self = getTopSelf();

        ThreadContext context = getCurrentContext();

        context.pushDynamicVars();

        RubyModule wrapper = context.getWrapper();
		RubyModule oldParent;

        if (!wrap) {
            secure(4); /* should alter global state */
            oldParent = context.setRubyClass(objectClass);
            context.setWrapper(null);
        } else {
            /* load in anonymous module as toplevel */
            context.setWrapper(RubyModule.newModule(this, null));
            oldParent = context.setRubyClass(context.getWrapper());
            self = getTopSelf().rbClone();
            self.extendObject(context.getRubyClass());
        }

        context.getFrameStack().push(new Frame(context, self, IRubyObject.NULL_ARRAY, null, null));
        context.getScopeStack().push(new Scope(this));

        /* default visibility is private at loading toplevel */
        setCurrentVisibility(Visibility.PRIVATE);

        try {
            self.eval(node);
        } catch (ReturnJump e) {
			// Make sure this does not bubble out to java caller.
        } finally {
            context.getScopeStack().pop();
            context.getFrameStack().pop();
            context.setRubyClass(oldParent);
            context.popDynamicVars();
            context.setWrapper(wrapper);
        }
    }


    /** Loads, compiles and interprets a Ruby file.
     *  Used by Kernel#require.
     *
     *  @mri rb_load
     */
    public void loadFile(File file, boolean wrap) {
        assert file != null : "No such file to load";
        try {
            BufferedReader source = new BufferedReader(new FileReader(file));
            loadScript(file.getPath(), source, wrap);
            source.close();
        } catch (IOException ioExcptn) {
            throw IOError.fromException(this, ioExcptn);
        }
    }

    /** Call the trace function
     *
     * MRI: eval.c - call_trace_func
     *
     */
    public synchronized void callTraceFunction(
        String event,
        SourcePosition position,
        IRubyObject self,
        String name,
        IRubyObject type) {
        if (!isWithinTrace && traceFunction != null) {
            isWithinTrace = true;

            SourcePosition savePosition = getPosition();
            String file = position.getFile();

            if (file == null) {
                file = "(ruby)";
            }
            if (type == null) {
				type = getFalse();
			}
            getFrameStack().push(new Frame(getCurrentContext(), Iter.ITER_NOT));

            try {
                traceFunction
                    .call(new IRubyObject[] {
                        newString(event),
                        newString(file),
                        newFixnum(position.getLine()),
                        name != null ? RubySymbol.newSymbol(this, name) : getNil(),
                        self != null ? self: getNil(),
                        type });
            } finally {
                getFrameStack().pop();
                setPosition(savePosition);
                isWithinTrace = false;
            }
        }
    }

    public RubyProc getTraceFunction() {
        return traceFunction;
    }

    public void setTraceFunction(RubyProc traceFunction) {
        this.traceFunction = traceFunction;
    }
    public GlobalVariables getGlobalVariables() {
        return globalVariables;
    }

    public CallbackFactory callbackFactory(Class type) {
        return CallbackFactory.createFactory(type);
    }

    /**
     * Push block onto exit stack.  When runtime environment exits
     * these blocks will be evaluated.
     * 
     * @return the element that was pushed onto stack
     */
    public IRubyObject pushExitBlock(RubyProc proc) {
    	atExitBlocks.push(proc);
        return proc;
    }
    
    /**
     * Make sure Kernel#at_exit procs get invoked on runtime shutdown.
     * This method needs to be explicitly called to work properly.
     * I thought about using finalize(), but that did not work and I
     * am not sure the runtime will be at a state to run procs by the
     * time Ruby is going away.  This method can contain any other
     * things that need to be cleaned up at shutdown.  
     */
    public void tearDown() {
        while (!atExitBlocks.empty()) {
            RubyProc proc = (RubyProc) atExitBlocks.pop();
            
            proc.call(IRubyObject.NULL_ARRAY);
        }
    }
    
    // new factory methods ------------------------------------------------------------------------
    
    public RubyArray newArray() {
    	return RubyArray.newArray(this);
    }
    
    public RubyArray newArray(IRubyObject object) {
    	return RubyArray.newArray(this, object);
    }

    public RubyArray newArray(IRubyObject car, IRubyObject cdr) {
    	return RubyArray.newArray(this, car, cdr);
    }
    
    public RubyArray newArray(IRubyObject[] objects) {
    	return RubyArray.newArray(this, objects);
    }
    
    public RubyArray newArray(List list) {
    	return RubyArray.newArray(this, list);
    }
    
    public RubyArray newArray(int size) {
    	return RubyArray.newArray(this, size);
    }
    
    public RubyBoolean newBoolean(boolean value) {
    	return RubyBoolean.newBoolean(this, value);
    }
    
    public RubyFileStat newRubyFileStat(File file) {
    	return new RubyFileStat(this, file);
    }
    
    public RubyFixnum newFixnum(long value) {
    	return RubyFixnum.newFixnum(this, value);
    }
    
    public RubyFloat newFloat(double value) {
    	return RubyFloat.newFloat(this, value);
    }

    public RubyNumeric newNumeric() {
    	return RubyNumeric.newNumeric(this);
    }
    
    public RubyProc newProc() {
    	return RubyProc.newProc(this, false);
    }

    public RubyString newString(String string) {
    	return RubyString.newString(this, string);
    }
    
    public RubySymbol newSymbol(String string) {
    	return RubySymbol.newSymbol(this, string);
    }
    
    public ArgumentError newArgumentError(String message) {
    	return new ArgumentError(this, message);
    }
    
    public ArgumentError newArgumentError(int got, int expected) {
    	return new ArgumentError(this, got, expected);
    }
    
    public EOFError newEOFError() {
    	return new EOFError(this);
    }
    
    public ErrnoError newErrnoEBADFError() {
    	return ErrnoError.getErrnoError(this, "EBADF", "Bad file descriptor");
    }

    public ErrnoError newErrnoEINVALError() {
    	return ErrnoError.getErrnoError(this, "EINVAL", "Invalid file");
    }

    public ErrnoError newErrnoENOENTError() {
    	return ErrnoError.getErrnoError(this, "ENOENT", "File not found");
    }

    public ErrnoError newErrnoESPIPEError() {
    	return ErrnoError.getErrnoError(this, "ESPIPE", "Illegal seek");
    }

    public IndexError newIndexError(String message) {
    	return new IndexError(this, message);
    }
    
    public IOError newIOError(String message) {
    	return new IOError(this, message);
    }
    
    public SecurityError newSecurityError(String message) {
    	return new SecurityError(this, message);
    }
    
    public SystemCallError newSystemCallError(String message) {
    	return new SystemCallError(this, message);
    }

    public TypeError newTypeError(String message) {
    	return new TypeError(this, message);
    }
    
    public TypeError newTypeError(IRubyObject receivedObject, RubyClass expectedClass) {
    	return new TypeError(this, receivedObject, expectedClass);
    }
}
