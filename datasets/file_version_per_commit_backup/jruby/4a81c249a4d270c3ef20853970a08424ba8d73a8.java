package org.jruby;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.Block;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ObjectMarshal;
import org.jruby.runtime.Visibility;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.builtin.Variable;
import org.jruby.runtime.component.VariableEntry;
import org.jruby.runtime.marshal.MarshalStream;
import org.jruby.runtime.marshal.UnmarshalStream;

public class RubySystemCallError extends RubyException {
    private IRubyObject errno;

    private final static Map<String, String> defaultMessages = new HashMap<String, String>();
    static {
        defaultMessages.put("Errno::EPERM", "Operation not permitted");
        defaultMessages.put("Errno::ENOENT", "No such file or directory");
        defaultMessages.put("Errno::ESRCH", "No such process");
        defaultMessages.put("Errno::EINTR", "Interrupted system call");
        defaultMessages.put("Errno::EIO", "Input/output error");
        defaultMessages.put("Errno::ENXIO", "Device not configured");
        defaultMessages.put("Errno::E2BIG", "Argument list too long");
        defaultMessages.put("Errno::ENOEXEC", "Exec format error");
        defaultMessages.put("Errno::EBADF", "Bad file descriptor");
        defaultMessages.put("Errno::ECHILD", "No child processes");
        defaultMessages.put("Errno::EDEADLK", "Resource deadlock avoided");
        defaultMessages.put("Errno::ENOMEM", "Cannot allocate memory");
        defaultMessages.put("Errno::EACCES", "Permission denied");
        defaultMessages.put("Errno::EFAULT", "Bad address");
        defaultMessages.put("Errno::ENOTBLK", "Block device required");
        defaultMessages.put("Errno::EBUSY", "Resource busy");
        defaultMessages.put("Errno::EEXIST", "File exists");
        defaultMessages.put("Errno::EXDEV", "Cross-device link");
        defaultMessages.put("Errno::ENODEV", "Operation not supported by device");
        defaultMessages.put("Errno::ENOTDIR", "Not a directory");
        defaultMessages.put("Errno::EISDIR", "Is a directory");
        defaultMessages.put("Errno::EINVAL", "Invalid argument");
        defaultMessages.put("Errno::ENFILE", "Too many open files in system");
        defaultMessages.put("Errno::EMFILE", "Too many open files");
        defaultMessages.put("Errno::ENOTTY", "Inappropriate ioctl for device");
        defaultMessages.put("Errno::ETXTBSY", "Text file busy");
        defaultMessages.put("Errno::EFBIG", "File too large");
        defaultMessages.put("Errno::ENOSPC", "No space left on device");
        defaultMessages.put("Errno::ESPIPE", "Illegal seek");
        defaultMessages.put("Errno::EROFS", "Read-only file system");
        defaultMessages.put("Errno::EMLINK", "Too many links");
        defaultMessages.put("Errno::EPIPE", "Broken pipe");
        defaultMessages.put("Errno::EDOM", "Numerical argument out of domain");
        defaultMessages.put("Errno::ERANGE", "Result too large");
        defaultMessages.put("Errno::EAGAIN", "Resource temporarily unavailable");
        defaultMessages.put("Errno::EAGAIN", "Resource temporarily unavailable");
        defaultMessages.put("Errno::EINPROGRESS", "Operation now in progress");
        defaultMessages.put("Errno::EALREADY", "Operation already in progress");
        defaultMessages.put("Errno::ENOTSOCK", "Socket operation on non-socket");
        defaultMessages.put("Errno::EDESTADDRREQ", "Destination address required");
        defaultMessages.put("Errno::EMSGSIZE", "Message too long");
        defaultMessages.put("Errno::EPROTOTYPE", "Protocol wrong type for socket");
        defaultMessages.put("Errno::ENOPROTOOPT", "Protocol not available");
        defaultMessages.put("Errno::EPROTONOSUPPORT", "Protocol not supported");
        defaultMessages.put("Errno::ESOCKTNOSUPPORT", "Socket type not supported");
        defaultMessages.put("Errno::EPFNOSUPPORT", "Protocol family not supported");
        defaultMessages.put("Errno::EAFNOSUPPORT", "Address family not supported by protocol family");
        defaultMessages.put("Errno::EADDRINUSE", "Address already in use");
        defaultMessages.put("Errno::EADDRNOTAVAIL", "Can't assign requested address");
        defaultMessages.put("Errno::ENETDOWN", "Network is down");
        defaultMessages.put("Errno::ENETUNREACH", "Network is unreachable");
        defaultMessages.put("Errno::ENETRESET", "Network dropped connection on reset");
        defaultMessages.put("Errno::ECONNABORTED", "Software caused connection abort");
        defaultMessages.put("Errno::ECONNRESET", "Connection reset by peer");
        defaultMessages.put("Errno::ENOBUFS", "No buffer space available");
        defaultMessages.put("Errno::EISCONN", "Socket is already connected");
        defaultMessages.put("Errno::ENOTCONN", "Socket is not connected");
        defaultMessages.put("Errno::ESHUTDOWN", "Can't send after socket shutdown");
        defaultMessages.put("Errno::ETOOMANYREFS", "Too many references: can't splice");
        defaultMessages.put("Errno::ETIMEDOUT", "Operation timed out");
        defaultMessages.put("Errno::ECONNREFUSED", "Connection refused");
        defaultMessages.put("Errno::ELOOP", "Too many levels of symbolic links");
        defaultMessages.put("Errno::ENAMETOOLONG", "File name too long");
        defaultMessages.put("Errno::EHOSTDOWN", "Host is down");
        defaultMessages.put("Errno::EHOSTUNREACH", "No route to host");
        defaultMessages.put("Errno::ENOTEMPTY", "Directory not empty");
        defaultMessages.put("Errno::EUSERS", "Too many users");
        defaultMessages.put("Errno::EDQUOT", "Disc quota exceeded");
        defaultMessages.put("Errno::ESTALE", "Stale NFS file handle");
        defaultMessages.put("Errno::EREMOTE", "Too many levels of remote in path");
        defaultMessages.put("Errno::ENOLCK", "No locks available");
        defaultMessages.put("Errno::ENOSYS", "Function not implemented");
        defaultMessages.put("Errno::EOVERFLOW", "Value too large to be stored in data type");
        defaultMessages.put("Errno::EIDRM", "Identifier removed");
        defaultMessages.put("Errno::ENOMSG", "No message of desired type");
        defaultMessages.put("Errno::EILSEQ", "Illegal byte sequence");
        defaultMessages.put("Errno::EBADMSG", "Bad message");
        defaultMessages.put("Errno::EMULTIHOP", "EMULTIHOP (Reserved)");
        defaultMessages.put("Errno::ENODATA", "No message available on STREAM");
        defaultMessages.put("Errno::ENOLINK", "ENOLINK (Reserved)");
        defaultMessages.put("Errno::ENOSR", "No STREAM resources");
        defaultMessages.put("Errno::ENOSTR", "Not a STREAM");
        defaultMessages.put("Errno::EPROTO", "Protocol error");
        defaultMessages.put("Errno::ETIME", "STREAM ioctl timeout");
        defaultMessages.put("Errno::EOPNOTSUPP", "Operation not supported");
    }

    protected RubySystemCallError(Ruby runtime, RubyClass rubyClass) {
        this(runtime, rubyClass, null, 0);
    }

    public RubySystemCallError(Ruby runtime, RubyClass rubyClass, String message, int errno) {
        super(runtime, rubyClass, message);
        
        this.errno = runtime.newFixnum(errno);
    }

    private static ObjectAllocator SYSTEM_CALL_ERROR_ALLOCATOR = new ObjectAllocator() {
        public IRubyObject allocate(Ruby runtime, RubyClass klass) {
            RubyException instance = new RubySystemCallError(runtime, klass);
            
            instance.setMetaClass(klass);
            
            return instance;
        }
    };
    
    private static final ObjectMarshal SYSTEM_CALL_ERROR_MARSHAL = new ObjectMarshal() {
        public void marshalTo(Ruby runtime, Object obj, RubyClass type,
                              MarshalStream marshalStream) throws IOException {
            RubySystemCallError exc = (RubySystemCallError) obj;
            marshalStream.registerLinkTarget(exc);
            
            List<Variable<IRubyObject>> attrs = exc.getVariableList();
            attrs.add(new VariableEntry<IRubyObject>(
                    "mesg", exc.message == null ? runtime.getNil() : exc.message));
            attrs.add(new VariableEntry<IRubyObject>("errno", exc.errno));
            attrs.add(new VariableEntry<IRubyObject>("bt", exc.getBacktrace()));
            marshalStream.dumpVariables(attrs);
        }

        public Object unmarshalFrom(Ruby runtime, RubyClass type,
            UnmarshalStream unmarshalStream) throws IOException {
            RubySystemCallError exc = (RubySystemCallError) type.allocate();
            
            unmarshalStream.registerLinkTarget(exc);
            unmarshalStream.defaultVariablesUnmarshal(exc);
            
            exc.message = exc.removeInternalVariable("mesg");
            exc.errno = exc.removeInternalVariable("errno");
            exc.set_backtrace(exc.removeInternalVariable("bt"));
            
            return exc;
        }
    };

    public static RubyClass createSystemCallErrorClass(Ruby runtime, RubyClass standardError) {
        RubyClass exceptionClass = runtime.defineClass("SystemCallError", standardError, SYSTEM_CALL_ERROR_ALLOCATOR);

        exceptionClass.setMarshal(SYSTEM_CALL_ERROR_MARSHAL);
        
        runtime.callbackFactory(RubyClass.class);
        exceptionClass.defineAnnotatedMethods(RubySystemCallError.class);

        return exceptionClass;
    }
    
    @JRubyMethod(optional = 2, required=0, frame = true, visibility = Visibility.PRIVATE)
    public IRubyObject initialize(IRubyObject[] args, Block block) {
        String name = getMetaClass().getRealClass().getName();
        if (args.length >= 1) message = args[0];
        if (args.length == 2) {
            errno = args[1].convertToInteger();
        }

        if(args.length == 0) {
            String val = defaultMessages.get(name);
            if(null == val) {
                val = name;
            } 

            message = getRuntime().newString(val);
        }

        return this;
    }

    @JRubyMethod
    public IRubyObject errno() {
        return errno;
    }
}