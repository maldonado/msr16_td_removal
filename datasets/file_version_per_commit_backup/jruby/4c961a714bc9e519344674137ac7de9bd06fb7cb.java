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
 * Copyright (C) 2001 Alan Moore <alan_moore@gmx.net>
 * Copyright (C) 2001-2002 Benoit Cerrina <b.cerrina@wanadoo.fr>
 * Copyright (C) 2001-2004 Jan Arne Petersen <jpetersen@uni-bonn.de>
 * Copyright (C) 2002-2004 Anders Bengtsson <ndrsbngtssn@yahoo.se>
 * Copyright (C) 2002-2006 Thomas E Enebo <enebo@acm.org>
 * Copyright (C) 2004 Stefan Matthias Aust <sma@3plus4.de>
 * Copyright (C) 2004 David Corbin <dcorbin@users.sourceforge.net>
 * Copyright (C) 2005 Tim Azzopardi <tim@tigerfive.com>
 * Copyright (C) 2006 Miguel Covarrubias <mlcovarrubias@gmail.com>
 * Copyright (C) 2006 Ola Bini <ola@ologix.com>
 * Copyright (C) 2007 Nick Sieger <nicksieger@gmail.com>
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

import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CodingErrorAction;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import jregex.Matcher;
import jregex.Pattern;

import org.jruby.runtime.Block;
import org.jruby.runtime.CallType;
import org.jruby.runtime.ClassIndex;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.marshal.UnmarshalStream;
import org.jruby.util.ByteList;
import org.jruby.util.KCode;
import org.jruby.util.Pack;
import org.jruby.util.Sprintf;

/**
 *
 * @author  jpetersen
 */
public class RubyString extends RubyObject {
    // Default record seperator
    private static final String DEFAULT_RS = "\n";

    public static final byte OP_PLUS_SWITCHVALUE = 1;
    public static final byte OP_LT_SWITCHVALUE = 2;
    public static final byte AREF_SWITCHVALUE = 3;
    public static final byte ASET_SWITCHVALUE = 4;
    public static final byte NIL_P_SWITCHVALUE = 5;
    public static final byte EQUALEQUAL_SWITCHVALUE = 6;
    public static final byte OP_GE_SWITCHVALUE = 7;
    public static final byte OP_LSHIFT_SWITCHVALUE = 8;
    public static final byte EMPTY_P_SWITCHVALUE = 9;
    public static final byte TO_S_SWITCHVALUE = 10;
    public static final byte TO_I_SWITCHVALUE = 11;

    private ByteList value;
    private int hash;
    private RubyFixnum r_hash;
    private boolean validHash = false;
    private String stringValue;

    // @see IRuby.newString(...)
    private RubyString(Ruby runtime, CharSequence value) {
            this(runtime, runtime.getString(), value);
    }

    private RubyString(Ruby runtime, byte[] value) {
            this(runtime, runtime.getString(), value);
    }

    private RubyString(Ruby runtime, ByteList value) {
            this(runtime, runtime.getString(), value);
    }

    private RubyString(Ruby runtime, RubyClass rubyClass, CharSequence value) {
        super(runtime, rubyClass);

        assert value != null;

        this.value = new ByteList(ByteList.plain(value),false);
    }

    private RubyString(Ruby runtime, RubyClass rubyClass, byte[] value) {
        super(runtime, rubyClass);

        assert value != null;

        this.value = new ByteList(value);
    }

    private RubyString(Ruby runtime, RubyClass rubyClass, ByteList value) {
        super(runtime, rubyClass);

        assert value != null;

        this.value = value;
    }

    public IRubyObject callMethod(ThreadContext context, RubyModule rubyclass, byte switchvalue, String name,
            IRubyObject[] args, CallType callType, Block block) {
        switch (switchvalue) {
        case OP_PLUS_SWITCHVALUE:
            if (args.length != 1) throw context.getRuntime().newArgumentError("wrong number of arguments(" + args.length + " for " + 1 + ")");
            return op_plus(args[0]);
        case OP_LT_SWITCHVALUE:
            if (args.length != 1) throw context.getRuntime().newArgumentError("wrong number of arguments(" + args.length + " for " + 1 + ")");
            return op_lt(args[0]);
        case AREF_SWITCHVALUE:
            return aref(args);
        case ASET_SWITCHVALUE:
            return aset(args);
        case NIL_P_SWITCHVALUE:
            if (args.length != 0) throw context.getRuntime().newArgumentError("wrong number of arguments(" + args.length + " for " + 0 + ")");
            return nil_p();
        case EQUALEQUAL_SWITCHVALUE:
            if (args.length != 1) throw context.getRuntime().newArgumentError("wrong number of arguments(" + args.length + " for " + 1 + ")");
            return eql(args[0]);
        case OP_GE_SWITCHVALUE:
            if (args.length != 1) throw context.getRuntime().newArgumentError("wrong number of arguments(" + args.length + " for " + 1 + ")");
            return op_ge(args[0]);
        case OP_LSHIFT_SWITCHVALUE:
            if (args.length != 1) throw context.getRuntime().newArgumentError("wrong number of arguments(" + args.length + " for " + 1 + ")");
            return concat(args[0]);
        case EMPTY_P_SWITCHVALUE:
            if (args.length != 0) throw context.getRuntime().newArgumentError("wrong number of arguments(" + args.length + " for " + 0 + ")");
            return empty();
        case TO_S_SWITCHVALUE:
            if (args.length != 0) throw context.getRuntime().newArgumentError("wrong number of arguments(" + args.length + " for " + 0 + ")");
            return to_s();
        case TO_I_SWITCHVALUE:
            return to_i(args);
        case 0:
        default:
            return super.callMethod(context, rubyclass, name, args, callType, block);
        }
    }

    public int getNativeTypeIndex() {
        return ClassIndex.STRING;
    }

    public Class getJavaClass() {
        return String.class;
    }

    /**
     * Remembers toString value, which is expensive for StringBuffer.
     */
    public String toString() {
        if (stringValue == null) {
            stringValue = new String(ByteList.plain(value.bytes),0,value.realSize);
        }
        return stringValue;
    }

    /**
     * This string has been changed, so invalidate stringValue.
     */
    private void stringMutated() {
        stringValue = null;
        validHash = false;
        taint();
    }

    public static String bytesToString(byte[] bytes, int beg, int len) {
        return new String(ByteList.plain(bytes), beg, len);
    }

    public static String byteListToString(ByteList bytes) {
        return bytesToString(bytes.unsafeBytes(),0,bytes.length());
    }

    public static String bytesToString(byte[] bytes) {
        return bytesToString(bytes,0,bytes.length);
    }

    public static byte[] stringToBytes(String string) {
        return ByteList.plain(string);
    }

    public static boolean isDigit(int c) {
        return c >= '0' && c <= '9';
    }

    public static boolean isUpper(int c) {
        return c >= 'A' && c <= 'Z';
    }

    public static boolean isLower(int c) {
        return c >= 'a' && c <= 'z';
    }

    public static boolean isLetter(int c) {
        return isUpper(c) || isLower(c);
    }

    public static boolean isAlnum(int c) {
        return isUpper(c) || isLower(c) || isDigit(c);
    }

    public static boolean isPrint(int c) {
        return c >= 0x20 && c <= 0x7E;
    }
    
    public IRubyObject checkStringType() {
        return this;
    }

    public IRubyObject to_s() {
        return this;
    }

    /* rb_str_cmp_m */
    public IRubyObject op_cmp(IRubyObject other) {
        if (other instanceof RubyString) {
            return getRuntime().newFixnum(cmp((RubyString)other));
        }

        // FIXME: This code does not appear to be applicable for <=> according to ri.
        // ri docs claim the other operand *must* be a String.
        /*ThreadContext context = getRuntime().getCurrentContext();

        if (other.respondsTo("to_str") && other.respondsTo("<=>")) {
            IRubyObject tmp = other.callMethod(context, "<=>", this);

            if (!tmp.isNil()) {
                return tmp instanceof RubyFixnum ? tmp.callMethod(context, "-") :
                    getRuntime().newFixnum(0).callMethod(context, "-", tmp);
            }
        }*/

        return getRuntime().getNil();
    }

    public IRubyObject eql(IRubyObject other) {
        Ruby runtime = getRuntime();
        if (other == this) {
            return runtime.getTrue();
        } else if (!(other instanceof RubyString)) {
            if(other.respondsTo("to_str")) {
                return other.callMethod(runtime.getCurrentContext(), "==", this);
            }
            return runtime.getFalse();
        }
        /* use Java implementation if both different String instances */
        return runtime.newBoolean(value.equals(((RubyString) other).value));
    }

    public IRubyObject op_plus(IRubyObject other) {
        RubyString str = RubyString.stringValue(other);

        ByteList newValue = new ByteList(value);
        newValue.append(str.value);
        return (RubyString) newString(getRuntime(), newValue).infectBy(str);
    }

    public IRubyObject op_mul(IRubyObject other) {
        RubyInteger otherInteger =
                (RubyInteger) other.convertType(RubyInteger.class, "Integer", "to_i");
        long len = otherInteger.getLongValue();

        if (len < 0) {
            throw getRuntime().newArgumentError("negative argument");
        }

        // we limit to int because ByteBuffer can only allocate int sizes
        if (len > 0 && Integer.MAX_VALUE / len < value.length()) {
            throw getRuntime().newArgumentError("argument too big");
        }
        ByteList newBytes = new ByteList(value.length() * (int)len);

        for (int i = 0; i < len; i++) {
            newBytes.append(value);
        }

        RubyString newString = newString(getRuntime(), newBytes);
        newString.setTaint(isTaint());
        return newString;
    }

    public IRubyObject format(IRubyObject arg) {
        // FIXME: Should we make this work with platform's locale, or continue hardcoding US?
        return getRuntime().newString((ByteList)Sprintf.sprintf(Locale.US,getByteList(),arg));
    }

    public RubyFixnum hash() {
        hashCode();
        return r_hash;
    }

    public int hashCode() {
        if(!validHash) {
            hash = value.hashCode();
            r_hash = getRuntime().newFixnum(hash);
            validHash = true;
        }
        return hash;
    }

    public boolean equals(Object other) {
        if (this == other) {
            return true;
        }

        if (other instanceof RubyString) {
            RubyString string = (RubyString)other;

            if (string.value.equals(value)) {
                return true;
            }
        }

        return false;
    }

    // Common enough check to make it a convenience method.
    private boolean sameAs(RubyString other) {
        return value.equals(other.value);
    }

    /** rb_obj_as_string
     *
     */
    public static RubyString objAsString(IRubyObject obj) {
        if (obj instanceof RubyString) return (RubyString) obj;

        IRubyObject str = obj.callMethod(obj.getRuntime().getCurrentContext(), "to_s");

        if (!(str instanceof RubyString)) return (RubyString) obj.anyToString();

        if (obj.isTaint()) str.setTaint(true);

        return (RubyString) str;
    }

    /** rb_str_cmp
     *
     */
    public int cmp(RubyString other) {
        return value.cmp(other.value);
    }

    /** rb_to_id
     *
     */
    public String asSymbol() {
        return toString();
    }


    /** Create a new String which uses the same Ruby runtime and the same
     *  class like this String.
     *
     *  This method should be used to satisfy RCR #38.
     *
     */
    public RubyString newString(CharSequence s) {
        return new RubyString(getRuntime(), getType(), s);
    }

    /** Create a new String which uses the same Ruby runtime and the same
     *  class like this String.
     *
     *  This method should be used to satisfy RCR #38.
     *
     */
    public RubyString newString(ByteList s) {
        return new RubyString(getRuntime(), getType(), s);
    }

    // Methods of the String class (rb_str_*):

    /** rb_str_new2
     *
     */
    public static RubyString newString(Ruby runtime, CharSequence str) {
        return new RubyString(runtime, str);
    }

    public static RubyString newString(Ruby runtime, byte[] bytes) {
        return new RubyString(runtime, bytes);
    }

    public static RubyString newString(Ruby runtime, ByteList bytes) {
        return new RubyString(runtime, bytes);
    }

    public static RubyString newString(Ruby runtime, byte[] bytes, int start, int length) {
        byte[] bytes2 = new byte[length];
        System.arraycopy(bytes, start, bytes2, 0, length);
        return new RubyString(runtime, bytes2);
    }

    public IRubyObject doClone(){
        return newString(getRuntime(), (ByteList)value.clone());
    }

    public RubyString cat(byte[] str) {
        value.append(str);
        stringMutated();
        return this;
    }

    public RubyString cat(ByteList str) {
        value.append(str);
        stringMutated();
        return this;
    }

    public RubyString cat(byte ch) {
        value.append(ch);
        stringMutated();
        return this;
    }

    public IRubyObject to_str() {
        if (getMetaClass().getRealClass() != getRuntime().getString()) {
            return newString(getRuntime(), value.bytes());
        }
        return this;
    }

    /** rb_str_replace_m
     *
     */
    public RubyString replace(IRubyObject other) {
        testFrozen("String");
         
        RubyString newValue = stringValue(other);
        if (this == other || sameAs(newValue)) {
            return this;
        }
        value.replace(newValue.value.bytes());
        stringMutated();
        return (RubyString) infectBy(newValue);
    }

    public RubyString reverse() {
        return newString(getRuntime(), (ByteList)value.clone()).reverse_bang();
    }

    public RubyString reverse_bang() {
        for (int i = 0; i < (value.length() / 2); i++) {
            byte b = (byte)value.get(i);
            value.set(i, value.get(value.length() - i - 1));
            value.set(value.length() - i - 1, b);
        }
        stringMutated();
        return this;
    }

    /** rb_str_s_new
     *
     */
    public static RubyString newInstance(IRubyObject recv, IRubyObject[] args, Block block) {
        RubyString newString = recv.getRuntime().newString("");
        newString.setMetaClass((RubyClass) recv);
        newString.callInit(args, block);
        return newString;
    }

    public IRubyObject initialize(IRubyObject[] args, Block unusedBlock) {
        if (checkArgumentCount(args, 0, 1) == 1) {
            replace(args[0]);
        }
        return this;
    }

    public IRubyObject casecmp(IRubyObject other) {
        int compare = toString().compareToIgnoreCase(stringValue(other).toString());
        return RubyFixnum.newFixnum(getRuntime(), compare == 0 ? 0 : (compare < 0 ? -1 : 1));
    }

    /** rb_str_match
     *
     */
    public IRubyObject match(IRubyObject other) {
        if (other instanceof RubyRegexp) {
            return ((RubyRegexp) other).match(this);
        } else if (other instanceof RubyString) {
            throw getRuntime().newTypeError("type mismatch: String given");
        }
        return other.callMethod(getRuntime().getCurrentContext(), "=~", this);
    }

    /** rb_str_match2
     *
     */
    public IRubyObject match2() {
        return RubyRegexp.newRegexp(this, 0, null).match2();
    }

    /**
     * String#match(pattern)
     *
     * @param pattern Regexp or String
     */
    public IRubyObject match3(IRubyObject pattern) {
        if (pattern instanceof RubyRegexp) {
            return ((RubyRegexp)pattern).search2(toString());
        } else if (pattern instanceof RubyString) {
            RubyRegexp regexp = RubyRegexp.newRegexp((RubyString) pattern, 0, null);
            return regexp.search2(toString());
        }

        return getRuntime().getNil();
    }

    /** rb_str_capitalize
     *
     */
    public IRubyObject capitalize() {
        RubyString result = (RubyString) dup();
        result.capitalize_bang();
        return result;
    }

    /** rb_str_capitalize_bang
     *
     */
    public IRubyObject capitalize_bang() {
        if (isEmpty()) {
            return getRuntime().getNil();
        }
        char capital = value.charAt(0);
        boolean changed = false;
        if (Character.isLetter(capital) && Character.isLowerCase(capital)) {
            value.set(0, (byte)Character.toUpperCase(capital));
            changed = true;
        }

        for (int i = 1; i < value.length(); i++) {
            capital = value.charAt(i);
            if (Character.isLetter(capital) && Character.isUpperCase(capital)) {
                value.set(i, (byte)Character.toLowerCase(capital));
                changed = true;
            }
        }

        if (changed) {
            stringMutated();
            return this;
        } else {
            return getRuntime().getNil();
        }
    }

    public IRubyObject op_ge(IRubyObject other) {
        if (other instanceof RubyString) {
            return getRuntime().newBoolean(cmp((RubyString) other) >= 0);
        }

        return RubyComparable.op_ge(this, other);
    }

    public IRubyObject op_gt(IRubyObject other) {
        if (other instanceof RubyString) {
            return getRuntime().newBoolean(cmp((RubyString) other) > 0);
        }

        return RubyComparable.op_gt(this, other);
    }

    public IRubyObject op_le(IRubyObject other) {
        if (other instanceof RubyString) {
            return getRuntime().newBoolean(cmp((RubyString) other) <= 0);
        }

        return RubyComparable.op_le(this, other);
    }

    public IRubyObject op_lt(IRubyObject other) {
        if (other instanceof RubyString) {
            return getRuntime().newBoolean(cmp((RubyString) other) < 0);
        }

        return RubyComparable.op_lt(this, other);
    }

    public IRubyObject op_eql(IRubyObject other) {
        return equals(other) ? other.getRuntime().getTrue() : other.getRuntime().getFalse();
    }

    /** rb_str_upcase
     *
     */
    public RubyString upcase() {
        return newString(toString().toUpperCase());
    }

    /** rb_str_upcase_bang
     *
     */
    public IRubyObject upcase_bang() {
        boolean changed = false;
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            if (!Character.isLetter(c) || Character.isUpperCase(c)) continue;
            value.set(i, (byte)Character.toUpperCase(c));
            changed = true;
        }
        if (changed) {
            stringMutated();
            return this;
        } else {
            return getRuntime().getNil();
        }
    }

    /** rb_str_downcase
     *
     */
    public RubyString downcase() {
        return newString(toString().toLowerCase());
    }

    /** rb_str_downcase_bang
     *
     */
    public IRubyObject downcase_bang() {
        boolean changed = false;
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            if (!Character.isLetter(c) || Character.isLowerCase(c)) continue;
            value.set(i, (byte)Character.toLowerCase(c));
            changed = true;
        }
        if (changed) {
            stringMutated();
            return this;
        } else {
            return getRuntime().getNil();
        }
    }

    /** rb_str_swapcase
     *
     */
    public RubyString swapcase() {
        RubyString newString = newString(getRuntime(), (ByteList)value.clone());
        IRubyObject swappedString = newString.swapcase_bang();

        return (RubyString) (swappedString.isNil() ? newString : swappedString);
    }

    /** rb_str_swapcase_bang
     *
     */
    public IRubyObject swapcase_bang() {
        boolean changesMade = false;

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);

            if (!Character.isLetter(c)) {
                continue;
            } else if (Character.isLowerCase(c)) {
                changesMade = true;
                value.set(i, (byte)Character.toUpperCase(c));
            } else {
                changesMade = true;
                value.set(i, (byte)Character.toLowerCase(c));
            }
        }
        if (changesMade) {
            stringMutated();
            return this;
        }
        return getRuntime().getNil();
    }

    /** rb_str_dump
     *
     */
    public RubyString dump() {
        return inspect(true);
    }

    public IRubyObject insert(IRubyObject indexArg, IRubyObject stringArg) {
        int index = (int) indexArg.convertToInteger().getLongValue();
        if (index < 0) {
            index += value.length() + 1;
        }

        if (index < 0 || index > value.length()) {
            throw getRuntime().newIndexError("index " + index + " out of range");
        }

        ByteList insert = ((RubyString)stringArg.convertToString()).value;
        value.unsafeReplace(index, 0, insert);
        stringMutated();
        return this;
    }

    /** rb_str_inspect
     *
     */
    public IRubyObject inspect() {
        return inspect(false);
    }

    private RubyString inspect(boolean dump) {
        final int length = value.length();
        Ruby runtime = getRuntime();

        StringBuffer sb = new StringBuffer(length + 2 + length / 100);

        sb.append('\"');

        // FIXME: This may not be unicode-safe
        for (int i = 0; i < length; i++) {
            int c = value.get(i) & 0xFF;
            if (isAlnum(c)) {
                sb.append((char)c);
            } else if (runtime.getKCode() == KCode.UTF8 && c == 0xEF) {
                // don't escape encoded UTF8 characters, leave them as bytes
                // append byte order mark plus two character bytes
                sb.append((char)c);
                sb.append((char)(value.get(++i) & 0xFF));
                sb.append((char)(value.get(++i) & 0xFF));
            } else if (c == '\"' || c == '\\') {
                sb.append('\\').append((char)c);
            } else if (dump && c == '#') {
                sb.append('\\').append((char)c);
            } else if (isPrint(c)) {
                sb.append((char)c);
            } else if (c == '\n') {
                sb.append('\\').append('n');
            } else if (c == '\r') {
                sb.append('\\').append('r');
            } else if (c == '\t') {
                sb.append('\\').append('t');
            } else if (c == '\f') {
                sb.append('\\').append('f');
            } else if (c == '\u000B') {
                sb.append('\\').append('v');
            } else if (c == '\u0007') {
                sb.append('\\').append('a');
            } else if (c == '\u001B') {
                sb.append('\\').append('e');
            } else {
                sb.append(Sprintf.sprintf(runtime,"\\%.3o",c));
            }
        }

        sb.append('\"');
        return getRuntime().newString(sb.toString());
    }

    /** rb_str_length
     *
     */
    public RubyFixnum length() {
        return getRuntime().newFixnum(value.length());
    }

    /** rb_str_empty
     *
     */
    public RubyBoolean empty() {
        return getRuntime().newBoolean(isEmpty());
    }

    private boolean isEmpty() {
        return value.length() == 0;
    }

    /** rb_str_append
     *
     */
    public RubyString append(IRubyObject other) {
        infectBy(other);
        return cat(stringValue(other).value);
    }

    /** rb_str_concat
     *
     */
    public RubyString concat(IRubyObject other) {
        if ((other instanceof RubyFixnum) && ((RubyFixnum) other).getLongValue() < 256) {
            return cat((byte) ((RubyFixnum) other).getLongValue());
        }
        return append(other);
    }

    /** rb_str_crypt
     *
     */
    public RubyString crypt(IRubyObject other) {
        String salt = stringValue(other).getValue().toString();
        if(salt.length()<2) {
            throw getRuntime().newArgumentError("salt too short(need >=2 bytes)");
        }

        salt = salt.substring(0,2);
        return getRuntime().newString(JavaCrypt.crypt(salt, this.toString()));
    }


    public static class JavaCrypt {
        private static java.util.Random r_gen = new java.util.Random();

        private static final char theBaseSalts[] = {
            'a','b','c','d','e','f','g','h','i','j','k','l','m',
            'n','o','p','q','r','s','t','u','v','w','x','y','z',
            'A','B','C','D','E','F','G','H','I','J','K','L','M',
            'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
            '0','1','2','3','4','5','6','7','8','9','/','.'};

        private static final int ITERATIONS = 16;

        private static final int con_salt[] = {
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
            0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,
            0x0A, 0x0B, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,
            0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12,
            0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A,
            0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x21, 0x22,
            0x23, 0x24, 0x25, 0x20, 0x21, 0x22, 0x23, 0x24,
            0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C,
            0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34,
            0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C,
            0x3D, 0x3E, 0x3F, 0x00, 0x00, 0x00, 0x00, 0x00,
        };

        private static final boolean shifts2[] = {
            false, false, true, true, true, true, true, true,
            false, true,  true, true, true, true, true, false };

        private static final int skb[][] = {
            {
                /* for C bits (numbered as per FIPS 46) 1 2 3 4 5 6 */
                0x00000000, 0x00000010, 0x20000000, 0x20000010,
                0x00010000, 0x00010010, 0x20010000, 0x20010010,
                0x00000800, 0x00000810, 0x20000800, 0x20000810,
                0x00010800, 0x00010810, 0x20010800, 0x20010810,
                0x00000020, 0x00000030, 0x20000020, 0x20000030,
                0x00010020, 0x00010030, 0x20010020, 0x20010030,
                0x00000820, 0x00000830, 0x20000820, 0x20000830,
                0x00010820, 0x00010830, 0x20010820, 0x20010830,
                0x00080000, 0x00080010, 0x20080000, 0x20080010,
                0x00090000, 0x00090010, 0x20090000, 0x20090010,
                0x00080800, 0x00080810, 0x20080800, 0x20080810,
                0x00090800, 0x00090810, 0x20090800, 0x20090810,
                0x00080020, 0x00080030, 0x20080020, 0x20080030,
                0x00090020, 0x00090030, 0x20090020, 0x20090030,
                0x00080820, 0x00080830, 0x20080820, 0x20080830,
                0x00090820, 0x00090830, 0x20090820, 0x20090830,
            },{
                /* for C bits (numbered as per FIPS 46) 7 8 10 11 12 13 */
                0x00000000, 0x02000000, 0x00002000, 0x02002000,
                0x00200000, 0x02200000, 0x00202000, 0x02202000,
                0x00000004, 0x02000004, 0x00002004, 0x02002004,
                0x00200004, 0x02200004, 0x00202004, 0x02202004,
                0x00000400, 0x02000400, 0x00002400, 0x02002400,
                0x00200400, 0x02200400, 0x00202400, 0x02202400,
                0x00000404, 0x02000404, 0x00002404, 0x02002404,
                0x00200404, 0x02200404, 0x00202404, 0x02202404,
                0x10000000, 0x12000000, 0x10002000, 0x12002000,
                0x10200000, 0x12200000, 0x10202000, 0x12202000,
                0x10000004, 0x12000004, 0x10002004, 0x12002004,
                0x10200004, 0x12200004, 0x10202004, 0x12202004,
                0x10000400, 0x12000400, 0x10002400, 0x12002400,
                0x10200400, 0x12200400, 0x10202400, 0x12202400,
                0x10000404, 0x12000404, 0x10002404, 0x12002404,
                0x10200404, 0x12200404, 0x10202404, 0x12202404,
            },{
                /* for C bits (numbered as per FIPS 46) 14 15 16 17 19 20 */
                0x00000000, 0x00000001, 0x00040000, 0x00040001,
                0x01000000, 0x01000001, 0x01040000, 0x01040001,
                0x00000002, 0x00000003, 0x00040002, 0x00040003,
                0x01000002, 0x01000003, 0x01040002, 0x01040003,
                0x00000200, 0x00000201, 0x00040200, 0x00040201,
                0x01000200, 0x01000201, 0x01040200, 0x01040201,
                0x00000202, 0x00000203, 0x00040202, 0x00040203,
                0x01000202, 0x01000203, 0x01040202, 0x01040203,
                0x08000000, 0x08000001, 0x08040000, 0x08040001,
                0x09000000, 0x09000001, 0x09040000, 0x09040001,
                0x08000002, 0x08000003, 0x08040002, 0x08040003,
                0x09000002, 0x09000003, 0x09040002, 0x09040003,
                0x08000200, 0x08000201, 0x08040200, 0x08040201,
                0x09000200, 0x09000201, 0x09040200, 0x09040201,
                0x08000202, 0x08000203, 0x08040202, 0x08040203,
                0x09000202, 0x09000203, 0x09040202, 0x09040203,
            },{
                /* for C bits (numbered as per FIPS 46) 21 23 24 26 27 28 */
                0x00000000, 0x00100000, 0x00000100, 0x00100100,
                0x00000008, 0x00100008, 0x00000108, 0x00100108,
                0x00001000, 0x00101000, 0x00001100, 0x00101100,
                0x00001008, 0x00101008, 0x00001108, 0x00101108,
                0x04000000, 0x04100000, 0x04000100, 0x04100100,
                0x04000008, 0x04100008, 0x04000108, 0x04100108,
                0x04001000, 0x04101000, 0x04001100, 0x04101100,
                0x04001008, 0x04101008, 0x04001108, 0x04101108,
                0x00020000, 0x00120000, 0x00020100, 0x00120100,
                0x00020008, 0x00120008, 0x00020108, 0x00120108,
                0x00021000, 0x00121000, 0x00021100, 0x00121100,
                0x00021008, 0x00121008, 0x00021108, 0x00121108,
                0x04020000, 0x04120000, 0x04020100, 0x04120100,
                0x04020008, 0x04120008, 0x04020108, 0x04120108,
                0x04021000, 0x04121000, 0x04021100, 0x04121100,
                0x04021008, 0x04121008, 0x04021108, 0x04121108,
            },{
                /* for D bits (numbered as per FIPS 46) 1 2 3 4 5 6 */
                0x00000000, 0x10000000, 0x00010000, 0x10010000,
                0x00000004, 0x10000004, 0x00010004, 0x10010004,
                0x20000000, 0x30000000, 0x20010000, 0x30010000,
                0x20000004, 0x30000004, 0x20010004, 0x30010004,
                0x00100000, 0x10100000, 0x00110000, 0x10110000,
                0x00100004, 0x10100004, 0x00110004, 0x10110004,
                0x20100000, 0x30100000, 0x20110000, 0x30110000,
                0x20100004, 0x30100004, 0x20110004, 0x30110004,
                0x00001000, 0x10001000, 0x00011000, 0x10011000,
                0x00001004, 0x10001004, 0x00011004, 0x10011004,
                0x20001000, 0x30001000, 0x20011000, 0x30011000,
                0x20001004, 0x30001004, 0x20011004, 0x30011004,
                0x00101000, 0x10101000, 0x00111000, 0x10111000,
                0x00101004, 0x10101004, 0x00111004, 0x10111004,
                0x20101000, 0x30101000, 0x20111000, 0x30111000,
                0x20101004, 0x30101004, 0x20111004, 0x30111004,
            },{
                /* for D bits (numbered as per FIPS 46) 8 9 11 12 13 14 */
                0x00000000, 0x08000000, 0x00000008, 0x08000008,
                0x00000400, 0x08000400, 0x00000408, 0x08000408,
                0x00020000, 0x08020000, 0x00020008, 0x08020008,
                0x00020400, 0x08020400, 0x00020408, 0x08020408,
                0x00000001, 0x08000001, 0x00000009, 0x08000009,
                0x00000401, 0x08000401, 0x00000409, 0x08000409,
                0x00020001, 0x08020001, 0x00020009, 0x08020009,
                0x00020401, 0x08020401, 0x00020409, 0x08020409,
                0x02000000, 0x0A000000, 0x02000008, 0x0A000008,
                0x02000400, 0x0A000400, 0x02000408, 0x0A000408,
                0x02020000, 0x0A020000, 0x02020008, 0x0A020008,
                0x02020400, 0x0A020400, 0x02020408, 0x0A020408,
                0x02000001, 0x0A000001, 0x02000009, 0x0A000009,
                0x02000401, 0x0A000401, 0x02000409, 0x0A000409,
                0x02020001, 0x0A020001, 0x02020009, 0x0A020009,
                0x02020401, 0x0A020401, 0x02020409, 0x0A020409,
            },{
                /* for D bits (numbered as per FIPS 46) 16 17 18 19 20 21 */
                0x00000000, 0x00000100, 0x00080000, 0x00080100,
                0x01000000, 0x01000100, 0x01080000, 0x01080100,
                0x00000010, 0x00000110, 0x00080010, 0x00080110,
                0x01000010, 0x01000110, 0x01080010, 0x01080110,
                0x00200000, 0x00200100, 0x00280000, 0x00280100,
                0x01200000, 0x01200100, 0x01280000, 0x01280100,
                0x00200010, 0x00200110, 0x00280010, 0x00280110,
                0x01200010, 0x01200110, 0x01280010, 0x01280110,
                0x00000200, 0x00000300, 0x00080200, 0x00080300,
                0x01000200, 0x01000300, 0x01080200, 0x01080300,
                0x00000210, 0x00000310, 0x00080210, 0x00080310,
                0x01000210, 0x01000310, 0x01080210, 0x01080310,
                0x00200200, 0x00200300, 0x00280200, 0x00280300,
                0x01200200, 0x01200300, 0x01280200, 0x01280300,
                0x00200210, 0x00200310, 0x00280210, 0x00280310,
                0x01200210, 0x01200310, 0x01280210, 0x01280310,
            },{
                /* for D bits (numbered as per FIPS 46) 22 23 24 25 27 28 */
                0x00000000, 0x04000000, 0x00040000, 0x04040000,
                0x00000002, 0x04000002, 0x00040002, 0x04040002,
                0x00002000, 0x04002000, 0x00042000, 0x04042000,
                0x00002002, 0x04002002, 0x00042002, 0x04042002,
                0x00000020, 0x04000020, 0x00040020, 0x04040020,
                0x00000022, 0x04000022, 0x00040022, 0x04040022,
                0x00002020, 0x04002020, 0x00042020, 0x04042020,
                0x00002022, 0x04002022, 0x00042022, 0x04042022,
                0x00000800, 0x04000800, 0x00040800, 0x04040800,
                0x00000802, 0x04000802, 0x00040802, 0x04040802,
                0x00002800, 0x04002800, 0x00042800, 0x04042800,
                0x00002802, 0x04002802, 0x00042802, 0x04042802,
                0x00000820, 0x04000820, 0x00040820, 0x04040820,
                0x00000822, 0x04000822, 0x00040822, 0x04040822,
                0x00002820, 0x04002820, 0x00042820, 0x04042820,
                0x00002822, 0x04002822, 0x00042822, 0x04042822,
            }
        };

        private static final int SPtrans[][] = {
            {
                /* nibble 0 */
                0x00820200, 0x00020000, 0x80800000, 0x80820200,
                0x00800000, 0x80020200, 0x80020000, 0x80800000,
                0x80020200, 0x00820200, 0x00820000, 0x80000200,
                0x80800200, 0x00800000, 0x00000000, 0x80020000,
                0x00020000, 0x80000000, 0x00800200, 0x00020200,
                0x80820200, 0x00820000, 0x80000200, 0x00800200,
                0x80000000, 0x00000200, 0x00020200, 0x80820000,
                0x00000200, 0x80800200, 0x80820000, 0x00000000,
                0x00000000, 0x80820200, 0x00800200, 0x80020000,
                0x00820200, 0x00020000, 0x80000200, 0x00800200,
                0x80820000, 0x00000200, 0x00020200, 0x80800000,
                0x80020200, 0x80000000, 0x80800000, 0x00820000,
                0x80820200, 0x00020200, 0x00820000, 0x80800200,
                0x00800000, 0x80000200, 0x80020000, 0x00000000,
                0x00020000, 0x00800000, 0x80800200, 0x00820200,
                0x80000000, 0x80820000, 0x00000200, 0x80020200,
            },{
                /* nibble 1 */
                0x10042004, 0x00000000, 0x00042000, 0x10040000,
                0x10000004, 0x00002004, 0x10002000, 0x00042000,
                0x00002000, 0x10040004, 0x00000004, 0x10002000,
                0x00040004, 0x10042000, 0x10040000, 0x00000004,
                0x00040000, 0x10002004, 0x10040004, 0x00002000,
                0x00042004, 0x10000000, 0x00000000, 0x00040004,
                0x10002004, 0x00042004, 0x10042000, 0x10000004,
                0x10000000, 0x00040000, 0x00002004, 0x10042004,
                0x00040004, 0x10042000, 0x10002000, 0x00042004,
                0x10042004, 0x00040004, 0x10000004, 0x00000000,
                0x10000000, 0x00002004, 0x00040000, 0x10040004,
                0x00002000, 0x10000000, 0x00042004, 0x10002004,
                0x10042000, 0x00002000, 0x00000000, 0x10000004,
                0x00000004, 0x10042004, 0x00042000, 0x10040000,
                0x10040004, 0x00040000, 0x00002004, 0x10002000,
                0x10002004, 0x00000004, 0x10040000, 0x00042000,
            },{
                /* nibble 2 */
                0x41000000, 0x01010040, 0x00000040, 0x41000040,
                0x40010000, 0x01000000, 0x41000040, 0x00010040,
                0x01000040, 0x00010000, 0x01010000, 0x40000000,
                0x41010040, 0x40000040, 0x40000000, 0x41010000,
                0x00000000, 0x40010000, 0x01010040, 0x00000040,
                0x40000040, 0x41010040, 0x00010000, 0x41000000,
                0x41010000, 0x01000040, 0x40010040, 0x01010000,
                0x00010040, 0x00000000, 0x01000000, 0x40010040,
                0x01010040, 0x00000040, 0x40000000, 0x00010000,
                0x40000040, 0x40010000, 0x01010000, 0x41000040,
                0x00000000, 0x01010040, 0x00010040, 0x41010000,
                0x40010000, 0x01000000, 0x41010040, 0x40000000,
                0x40010040, 0x41000000, 0x01000000, 0x41010040,
                0x00010000, 0x01000040, 0x41000040, 0x00010040,
                0x01000040, 0x00000000, 0x41010000, 0x40000040,
                0x41000000, 0x40010040, 0x00000040, 0x01010000,
            },{
                /* nibble 3 */
                0x00100402, 0x04000400, 0x00000002, 0x04100402,
                0x00000000, 0x04100000, 0x04000402, 0x00100002,
                0x04100400, 0x04000002, 0x04000000, 0x00000402,
                0x04000002, 0x00100402, 0x00100000, 0x04000000,
                0x04100002, 0x00100400, 0x00000400, 0x00000002,
                0x00100400, 0x04000402, 0x04100000, 0x00000400,
                0x00000402, 0x00000000, 0x00100002, 0x04100400,
                0x04000400, 0x04100002, 0x04100402, 0x00100000,
                0x04100002, 0x00000402, 0x00100000, 0x04000002,
                0x00100400, 0x04000400, 0x00000002, 0x04100000,
                0x04000402, 0x00000000, 0x00000400, 0x00100002,
                0x00000000, 0x04100002, 0x04100400, 0x00000400,
                0x04000000, 0x04100402, 0x00100402, 0x00100000,
                0x04100402, 0x00000002, 0x04000400, 0x00100402,
                0x00100002, 0x00100400, 0x04100000, 0x04000402,
                0x00000402, 0x04000000, 0x04000002, 0x04100400,
            },{
                /* nibble 4 */
                0x02000000, 0x00004000, 0x00000100, 0x02004108,
                0x02004008, 0x02000100, 0x00004108, 0x02004000,
                0x00004000, 0x00000008, 0x02000008, 0x00004100,
                0x02000108, 0x02004008, 0x02004100, 0x00000000,
                0x00004100, 0x02000000, 0x00004008, 0x00000108,
                0x02000100, 0x00004108, 0x00000000, 0x02000008,
                0x00000008, 0x02000108, 0x02004108, 0x00004008,
                0x02004000, 0x00000100, 0x00000108, 0x02004100,
                0x02004100, 0x02000108, 0x00004008, 0x02004000,
                0x00004000, 0x00000008, 0x02000008, 0x02000100,
                0x02000000, 0x00004100, 0x02004108, 0x00000000,
                0x00004108, 0x02000000, 0x00000100, 0x00004008,
                0x02000108, 0x00000100, 0x00000000, 0x02004108,
                0x02004008, 0x02004100, 0x00000108, 0x00004000,
                0x00004100, 0x02004008, 0x02000100, 0x00000108,
                0x00000008, 0x00004108, 0x02004000, 0x02000008,
            },{
                /* nibble 5 */
                0x20000010, 0x00080010, 0x00000000, 0x20080800,
                0x00080010, 0x00000800, 0x20000810, 0x00080000,
                0x00000810, 0x20080810, 0x00080800, 0x20000000,
                0x20000800, 0x20000010, 0x20080000, 0x00080810,
                0x00080000, 0x20000810, 0x20080010, 0x00000000,
                0x00000800, 0x00000010, 0x20080800, 0x20080010,
                0x20080810, 0x20080000, 0x20000000, 0x00000810,
                0x00000010, 0x00080800, 0x00080810, 0x20000800,
                0x00000810, 0x20000000, 0x20000800, 0x00080810,
                0x20080800, 0x00080010, 0x00000000, 0x20000800,
                0x20000000, 0x00000800, 0x20080010, 0x00080000,
                0x00080010, 0x20080810, 0x00080800, 0x00000010,
                0x20080810, 0x00080800, 0x00080000, 0x20000810,
                0x20000010, 0x20080000, 0x00080810, 0x00000000,
                0x00000800, 0x20000010, 0x20000810, 0x20080800,
                0x20080000, 0x00000810, 0x00000010, 0x20080010,
            },{
                /* nibble 6 */
                0x00001000, 0x00000080, 0x00400080, 0x00400001,
                0x00401081, 0x00001001, 0x00001080, 0x00000000,
                0x00400000, 0x00400081, 0x00000081, 0x00401000,
                0x00000001, 0x00401080, 0x00401000, 0x00000081,
                0x00400081, 0x00001000, 0x00001001, 0x00401081,
                0x00000000, 0x00400080, 0x00400001, 0x00001080,
                0x00401001, 0x00001081, 0x00401080, 0x00000001,
                0x00001081, 0x00401001, 0x00000080, 0x00400000,
                0x00001081, 0x00401000, 0x00401001, 0x00000081,
                0x00001000, 0x00000080, 0x00400000, 0x00401001,
                0x00400081, 0x00001081, 0x00001080, 0x00000000,
                0x00000080, 0x00400001, 0x00000001, 0x00400080,
                0x00000000, 0x00400081, 0x00400080, 0x00001080,
                0x00000081, 0x00001000, 0x00401081, 0x00400000,
                0x00401080, 0x00000001, 0x00001001, 0x00401081,
                0x00400001, 0x00401080, 0x00401000, 0x00001001,
            },{
                /* nibble 7 */
                0x08200020, 0x08208000, 0x00008020, 0x00000000,
                0x08008000, 0x00200020, 0x08200000, 0x08208020,
                0x00000020, 0x08000000, 0x00208000, 0x00008020,
                0x00208020, 0x08008020, 0x08000020, 0x08200000,
                0x00008000, 0x00208020, 0x00200020, 0x08008000,
                0x08208020, 0x08000020, 0x00000000, 0x00208000,
                0x08000000, 0x00200000, 0x08008020, 0x08200020,
                0x00200000, 0x00008000, 0x08208000, 0x00000020,
                0x00200000, 0x00008000, 0x08000020, 0x08208020,
                0x00008020, 0x08000000, 0x00000000, 0x00208000,
                0x08200020, 0x08008020, 0x08008000, 0x00200020,
                0x08208000, 0x00000020, 0x00200020, 0x08008000,
                0x08208020, 0x00200000, 0x08200000, 0x08000020,
                0x00208000, 0x00008020, 0x08008020, 0x08200000,
                0x00000020, 0x08208000, 0x00208020, 0x00000000,
                0x08000000, 0x08200020, 0x00008000, 0x00208020
            }
        };

        private static final int cov_2char[] = {
            0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35,
            0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44,
            0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C,
            0x4D, 0x4E, 0x4F, 0x50, 0x51, 0x52, 0x53, 0x54,
            0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x61, 0x62,
            0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A,
            0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70, 0x71, 0x72,
            0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A
        };

        private static final int byteToUnsigned(byte b) {
            return b & 0xFF;
        }

        private static int fourBytesToInt(byte b[], int offset) {
            int value;
            value  =  byteToUnsigned(b[offset++]);
            value |= (byteToUnsigned(b[offset++]) <<  8);
            value |= (byteToUnsigned(b[offset++]) << 16);
            value |= (byteToUnsigned(b[offset++]) << 24);
            return(value);
        }

        private static final void intToFourBytes(int iValue, byte b[], int offset) {
            b[offset++] = (byte)((iValue)        & 0xff);
            b[offset++] = (byte)((iValue >>> 8 ) & 0xff);
            b[offset++] = (byte)((iValue >>> 16) & 0xff);
            b[offset++] = (byte)((iValue >>> 24) & 0xff);
        }

        private static final void PERM_OP(int a, int b, int n, int m, int results[]) {
            int t;

            t = ((a >>> n) ^ b) & m;
            a ^= t << n;
            b ^= t;

            results[0] = a;
            results[1] = b;
        }

        private static final int HPERM_OP(int a, int n, int m) {
            int t;

            t = ((a << (16 - n)) ^ a) & m;
            a = a ^ t ^ (t >>> (16 - n));

            return(a);
        }

        private static int [] des_set_key(byte key[]) {
            int schedule[] = new int[ITERATIONS * 2];

            int c = fourBytesToInt(key, 0);
            int d = fourBytesToInt(key, 4);

            int results[] = new int[2];

            PERM_OP(d, c, 4, 0x0f0f0f0f, results);
            d = results[0]; c = results[1];

            c = HPERM_OP(c, -2, 0xcccc0000);
            d = HPERM_OP(d, -2, 0xcccc0000);

            PERM_OP(d, c, 1, 0x55555555, results);
            d = results[0]; c = results[1];

            PERM_OP(c, d, 8, 0x00ff00ff, results);
            c = results[0]; d = results[1];

            PERM_OP(d, c, 1, 0x55555555, results);
            d = results[0]; c = results[1];

            d = (((d & 0x000000ff) <<  16) |  (d & 0x0000ff00)     |
                 ((d & 0x00ff0000) >>> 16) | ((c & 0xf0000000) >>> 4));
            c &= 0x0fffffff;

            int s, t;
            int j = 0;

            for(int i = 0; i < ITERATIONS; i ++) {
                if(shifts2[i]) {
                    c = (c >>> 2) | (c << 26);
                    d = (d >>> 2) | (d << 26);
                } else {
                    c = (c >>> 1) | (c << 27);
                    d = (d >>> 1) | (d << 27);
                }

                c &= 0x0fffffff;
                d &= 0x0fffffff;

                s = skb[0][ (c       ) & 0x3f                       ]|
                    skb[1][((c >>>  6) & 0x03) | ((c >>>  7) & 0x3c)]|
                    skb[2][((c >>> 13) & 0x0f) | ((c >>> 14) & 0x30)]|
                    skb[3][((c >>> 20) & 0x01) | ((c >>> 21) & 0x06) |
                           ((c >>> 22) & 0x38)];

                t = skb[4][ (d     )  & 0x3f                       ]|
                    skb[5][((d >>> 7) & 0x03) | ((d >>>  8) & 0x3c)]|
                    skb[6][ (d >>>15) & 0x3f                       ]|
                    skb[7][((d >>>21) & 0x0f) | ((d >>> 22) & 0x30)];

                schedule[j++] = ((t <<  16) | (s & 0x0000ffff)) & 0xffffffff;
                s             = ((s >>> 16) | (t & 0xffff0000));

                s             = (s << 4) | (s >>> 28);
                schedule[j++] = s & 0xffffffff;
            }
            return(schedule);
        }

        private static final int D_ENCRYPT(int L, int R, int S, int E0, int E1, int s[]) {
            int t, u, v;

            v = R ^ (R >>> 16);
            u = v & E0;
            v = v & E1;
            u = (u ^ (u << 16)) ^ R ^ s[S];
            t = (v ^ (v << 16)) ^ R ^ s[S + 1];
            t = (t >>> 4) | (t << 28);

            L ^= SPtrans[1][(t       ) & 0x3f] |
                SPtrans[3][(t >>>  8) & 0x3f] |
                SPtrans[5][(t >>> 16) & 0x3f] |
                SPtrans[7][(t >>> 24) & 0x3f] |
                SPtrans[0][(u       ) & 0x3f] |
                SPtrans[2][(u >>>  8) & 0x3f] |
                SPtrans[4][(u >>> 16) & 0x3f] |
                SPtrans[6][(u >>> 24) & 0x3f];

            return(L);
        }

        private static final int [] body(int schedule[], int Eswap0, int Eswap1) {
            int left = 0;
            int right = 0;
            int t     = 0;

            for(int j = 0; j < 25; j ++) {
                for(int i = 0; i < ITERATIONS * 2; i += 4) {
                    left  = D_ENCRYPT(left,  right, i,     Eswap0, Eswap1, schedule);
                    right = D_ENCRYPT(right, left,  i + 2, Eswap0, Eswap1, schedule);
                }
                t     = left;
                left  = right;
                right = t;
            }

            t = right;

            right = (left >>> 1) | (left << 31);
            left  = (t    >>> 1) | (t    << 31);

            left  &= 0xffffffff;
            right &= 0xffffffff;

            int results[] = new int[2];

            PERM_OP(right, left, 1, 0x55555555, results);
            right = results[0]; left = results[1];

            PERM_OP(left, right, 8, 0x00ff00ff, results);
            left = results[0]; right = results[1];

            PERM_OP(right, left, 2, 0x33333333, results);
            right = results[0]; left = results[1];

            PERM_OP(left, right, 16, 0x0000ffff, results);
            left = results[0]; right = results[1];

            PERM_OP(right, left, 4, 0x0f0f0f0f, results);
            right = results[0]; left = results[1];

            int out[] = new int[2];

            out[0] = left; out[1] = right;

            return(out);
        }

        public static final String crypt(String salt, String original) {
            while(salt.length() < 2)
                salt += getSaltChar();

            StringBuffer buffer = new StringBuffer("             ");

            char charZero = salt.charAt(0);
            char charOne  = salt.charAt(1);

            buffer.setCharAt(0, charZero);
            buffer.setCharAt(1, charOne);

            int Eswap0 = con_salt[(int)charZero];
            int Eswap1 = con_salt[(int)charOne] << 4;

            byte key[] = new byte[8];

            for(int i = 0; i < key.length; i ++) {
                key[i] = (byte)0;
            }

            for(int i = 0; i < key.length && i < original.length(); i ++) {
                int iChar = (int)original.charAt(i);

                key[i] = (byte)(iChar << 1);
            }

            int schedule[] = des_set_key(key);
            int out[]      = body(schedule, Eswap0, Eswap1);

            byte b[] = new byte[9];

            intToFourBytes(out[0], b, 0);
            intToFourBytes(out[1], b, 4);
            b[8] = 0;

            for(int i = 2, y = 0, u = 0x80; i < 13; i ++) {
                for(int j = 0, c = 0; j < 6; j ++) {
                    c <<= 1;

                    if(((int)b[y] & u) != 0)
                        c |= 1;

                    u >>>= 1;

                    if(u == 0) {
                        y++;
                        u = 0x80;
                    }
                    buffer.setCharAt(i, (char)cov_2char[c]);
                }
            }
            return(buffer.toString());
        }

        private static String getSaltChar() {
            return JavaCrypt.getSaltChar(1);
        }

        private static String getSaltChar(int amount) {
            StringBuffer sb = new StringBuffer();
            for(int i=amount;i>0;i--) {
                sb.append(theBaseSalts[(Math.abs(r_gen.nextInt())%64)]);
            }
            return sb.toString();
        }

        public static boolean check(String theClear,String theCrypt) {
            String theTest = JavaCrypt.crypt(theCrypt.substring(0,2),theClear);
            return theTest.equals(theCrypt);
        }

        public static String crypt(String theClear) {
            return JavaCrypt.crypt(getSaltChar(2),theClear);
        }
    }

    /* RubyString aka rb_string_value */
    public static RubyString stringValue(IRubyObject object) {
        return (RubyString) (object instanceof RubyString ? object :
            object.convertType(RubyString.class, "String", "to_str"));
    }

    /** rb_str_sub
     *
     */
    public IRubyObject sub(IRubyObject[] args, Block block) {
        return sub(args, false, block);
    }

    /** rb_str_sub_bang
     *
     */
    public IRubyObject sub_bang(IRubyObject[] args, Block block) {
        return sub(args, true, block);
    }

    private IRubyObject sub(IRubyObject[] args, boolean bang, Block block) {
        IRubyObject repl = getRuntime().getNil();
        boolean iter = false;
        ThreadContext tc = getRuntime().getCurrentContext();

        if (args.length == 1 && block.isGiven()) {
            iter = true;
        } else if (args.length == 2) {
            repl = args[1];
        } else {
            throw getRuntime().newArgumentError("wrong number of arguments");
        }
        RubyRegexp pat = RubyRegexp.regexpValue(args[0]);

        String intern = toString();

        if (pat.search(intern, 0) >= 0) {
            RubyMatchData match = (RubyMatchData) tc.getBackref();
            RubyString newStr = match.pre_match();
            newStr.append(iter ? block.yield(tc, match.group(0)) : pat.regsub(repl, match));
            newStr.append(match.post_match());
            newStr.setTaint(isTaint() || repl.isTaint());
            if (bang) {
                value = newStr.value;
                stringMutated();
                return this;
            }

            return newStr;
        }

        return bang ? getRuntime().getNil() : this;
    }

    /** rb_str_gsub
     *
     */
    public IRubyObject gsub(IRubyObject[] args, Block block) {
        return gsub(args, false, block);
    }

    /** rb_str_gsub_bang
     *
     */
    public IRubyObject gsub_bang(IRubyObject[] args, Block block) {
        return gsub(args, true, block);
    }

    private IRubyObject gsub(IRubyObject[] args, boolean bang, Block block) {
        // TODO: improve implementation. this is _really_ slow
        IRubyObject repl = getRuntime().getNil();
        RubyMatchData match;
        boolean iter = false;
        if (args.length == 1 && block.isGiven()) {
            iter = true;
        } else if (args.length == 2) {
            repl = args[1];
        } else {
            throw getRuntime().newArgumentError("wrong number of arguments");
        }
        boolean taint = repl.isTaint();
        RubyRegexp pat = RubyRegexp.regexpValue(args[0]);

        String str = toString();
        int beg = pat.search(str, 0);
        if (beg < 0) {
            return bang ? getRuntime().getNil() : dup();
        }
        ByteList sbuf = new ByteList(this.value.length());
        IRubyObject newStr;
        int offset = 0;

        // Fix for JRUBY-97: Temporary fix pending
        // decision on UTF8-based string implementation.
        ThreadContext tc = getRuntime().getCurrentContext();
        if(iter) {
            while (beg >= 0) {
                match = (RubyMatchData) tc.getBackref();
                sbuf.append(this.value,offset,beg-offset);
                newStr = block.yield(tc, match.group(0));
                taint |= newStr.isTaint();
                sbuf.append(newStr.objAsString().getByteList());
                offset = match.matchEndPosition();
                beg = pat.search(str, offset == beg ? beg + 1 : offset);
            }
        } else {
            RubyString r = stringValue(repl);
            while (beg >= 0) {
                match = (RubyMatchData) tc.getBackref();
                sbuf.append(this.value,offset,beg-offset);
                pat.regsub(r, match, sbuf);
                offset = match.matchEndPosition();
                beg = pat.search(str, offset == beg ? beg + 1 : offset);
            }
        }

        sbuf.append(this.value,offset,this.value.length()-offset);

        if (bang) {
            setTaint(isTaint() || taint);
            setValue(sbuf);
            return this;
        }
        RubyString result = newString(sbuf);
        result.setTaint(isTaint() || taint);
        return result;
    }

    /** rb_str_index_m
     *
     */
    public IRubyObject index(IRubyObject[] args) {
        return index(args, false);
    }

    /** rb_str_rindex_m
     *
     */
    public IRubyObject rindex(IRubyObject[] args) {
        return index(args, true);
    }

    /**
     *	@fixme may be a problem with pos when doing reverse searches
     */
    private IRubyObject index(IRubyObject[] args, boolean reverse) {
        //FIXME may be a problem with pos when doing reverse searches
        int pos = 0;
        if (reverse) {
            pos = value.length();
        }
        if (checkArgumentCount(args, 1, 2) == 2) {
            pos = RubyNumeric.fix2int(args[1]);
        }
        if (pos < 0) {
            pos += value.length();
            if (pos < 0) {
                return getRuntime().getNil();
            }
        }
        if (args[0] instanceof RubyRegexp) {
            int doNotLookPastIfReverse = pos;

            // RubyRegexp doesn't (yet?) support reverse searches, so we
            // find all matches and use the last one--very inefficient.
            // XXX - find a better way
            pos = ((RubyRegexp) args[0]).search(toString(), reverse ? 0 : pos);

            int dummy = pos;
            while (reverse && dummy > -1 && dummy <= doNotLookPastIfReverse) {
                pos = dummy;
                dummy = ((RubyRegexp) args[0]).search(toString(), pos + 1);
            }
        } else if (args[0] instanceof RubyString) {
            String sub = ((RubyString) args[0]).toString();
            StringBuffer sb = new StringBuffer(toString());
            pos = reverse ? sb.lastIndexOf(sub, pos) : sb.indexOf(sub, pos);
        } else if (args[0] instanceof RubyFixnum) {
            char c = (char) ((RubyFixnum) args[0]).getLongValue();
            pos = reverse ? toString().lastIndexOf(c, pos) : toString().indexOf(c, pos);
        } else {
            throw getRuntime().newArgumentError("wrong type of argument");
        }

        return pos == -1 ? getRuntime().getNil() : getRuntime().newFixnum(pos);
    }

    /* rb_str_substr */
    public IRubyObject substr(int beg, int len) {
        int length = value.length();
        if (len < 0 || beg > length) {
            return getRuntime().getNil();
        }
        if (beg < 0) {
            beg += length;
            if (beg < 0) {
                return getRuntime().getNil();
            }
        }
        int end = Math.min(length, beg + len);
        ByteList newValue = new ByteList(value, beg, end - beg);
        return newString(getRuntime(), newValue).infectBy(this);
    }

    /* rb_str_replace */
    public IRubyObject replace(int beg, int len, RubyString replaceWith) {
        if (beg + len >= value.length()) {
            len = value.length() - beg;
        }

        value.unsafeReplace(beg,len,replaceWith.value);
        stringMutated();
        return infectBy(replaceWith);
    }

    /** rb_str_aref, rb_str_aref_m
     *
     */
    public IRubyObject aref(IRubyObject[] args) {
        if (checkArgumentCount(args, 1, 2) == 2) {
            if (args[0] instanceof RubyRegexp) {
                IRubyObject match = RubyRegexp.regexpValue(args[0]).match(toString(), 0);
                long idx = args[1].convertToInteger().getLongValue();
                getRuntime().getCurrentContext().setBackref(match);
                return RubyRegexp.nth_match((int) idx, match);
            }
            return substr(RubyNumeric.fix2int(args[0]), RubyNumeric.fix2int(args[1]));
        }

        if (args[0] instanceof RubyRegexp) {
            return RubyRegexp.regexpValue(args[0]).search(toString(), 0) >= 0 ?
                RubyRegexp.last_match(getRuntime().getCurrentContext().getBackref()) :
                getRuntime().getNil();
        } else if (args[0] instanceof RubyString) {
            return toString().indexOf(stringValue(args[0]).toString()) != -1 ?
                args[0] : getRuntime().getNil();
        } else if (args[0] instanceof RubyRange) {
            long[] begLen = ((RubyRange) args[0]).getBeginLength(value.length(), true, false);
            return begLen == null ? getRuntime().getNil() :
                substr((int) begLen[0], (int) begLen[1]);
        }
        int idx = (int) args[0].convertToInteger().getLongValue();
        if (idx < 0) {
            idx += value.length();
        }
        if (idx < 0 || idx >= value.length()) {
            return getRuntime().getNil();
        } else {
            RubyFixnum result = getRuntime().newFixnum(value.get(idx) & 0xFF);
            return result;
        }
    }

    /**
     * rb_str_subpat_set
     *
     */
    private void subpatSet(RubyRegexp regexp, int nth, IRubyObject repl) {
        int found = regexp.search(this.toString(), 0);
        if (found == -1) {
            throw getRuntime().newIndexError("regexp not matched");
        }

        RubyMatchData match = (RubyMatchData) getRuntime().getCurrentContext()
                .getBackref();

        if (nth >= match.getSize()) {
            throw getRuntime().newIndexError("index " + nth + " out of regexp");
        }
        if (nth < 0) {
            if (-nth >= match.getSize()) {
                throw getRuntime().newIndexError("index " + nth + " out of regexp");
            }
            nth += match.getSize();
        }

        IRubyObject group = match.group(nth);
        if (getRuntime().getNil().equals(group)) {
            throw getRuntime().newIndexError(
                    "regexp group " + nth + " not matched");
        }

        int beg = (int) match.begin(nth);
        int len = (int) (match.end(nth) - beg);

        replace(beg, len, stringValue(repl));

    }

    /** rb_str_aset, rb_str_aset_m
     *
     */
    public IRubyObject aset(IRubyObject[] args) {
        testFrozen("class");
        int strLen = value.length();
        if (checkArgumentCount(args, 2, 3) == 3) {
            if (args[0] instanceof RubyFixnum) {
                RubyString repl = stringValue(args[2]);
                int beg = RubyNumeric.fix2int(args[0]);
                int len = RubyNumeric.fix2int(args[1]);
                if (len < 0) {
                    throw getRuntime().newIndexError("negative length");
                }
                if (beg < 0) {
                    beg += strLen;
                }
                if (beg < 0 || (beg > 0 && beg >= strLen)) {
                    throw getRuntime().newIndexError(
                            "string index out of bounds");
                }
                if (beg + len > strLen) {
                    len = strLen - beg;
                }
                replace(beg, len, repl);
                return repl;
            }
            if (args[0] instanceof RubyRegexp) {
                RubyString repl = stringValue(args[2]);
                int nth = RubyNumeric.fix2int(args[1]);
                subpatSet((RubyRegexp) args[0], nth, repl);
                return repl;
            }
        }
        if (args[0] instanceof RubyFixnum) { // RubyNumeric?
            int idx = RubyNumeric.fix2int(args[0]); // num2int?
            if (idx < 0) {
                idx += value.length();
            }
            if (idx < 0 || idx >= value.length()) {
                throw getRuntime().newIndexError("string index out of bounds");
            }
            if (args[1] instanceof RubyFixnum) {
                value.set(idx, (byte) RubyNumeric.fix2int(args[1]));
                stringMutated();
            } else {
                replace(idx, 1, stringValue(args[1]));
            }
            return args[1];
        }
        if (args[0] instanceof RubyRegexp) {
            sub_bang(args, null);
            return args[1];
        }
        if (args[0] instanceof RubyString) {
            RubyString orig = stringValue(args[0]);
            int beg = toString().indexOf(orig.toString());
            if (beg != -1) {
                replace(beg, orig.value.length(), stringValue(args[1]));
            }
            return args[1];
        }
        if (args[0] instanceof RubyRange) {
            long[] idxs = ((RubyRange) args[0]).getBeginLength(value.length(), true, true);
            replace((int) idxs[0], (int) idxs[1], stringValue(args[1]));
            return args[1];
        }
        throw getRuntime().newTypeError("wrong argument type");
    }

    /** rb_str_slice_bang
     *
     */
    public IRubyObject slice_bang(IRubyObject[] args) {
        int argc = checkArgumentCount(args, 1, 2);
        IRubyObject[] newArgs = new IRubyObject[argc + 1];
        newArgs[0] = args[0];
        if (argc > 1) {
            newArgs[1] = args[1];
        }
        newArgs[argc] = newString("");
        IRubyObject result = aref(args);
        if (result.isNil()) {
            return result;
        }
        aset(newArgs);
        return result;
    }

    public IRubyObject succ() {
        return ((RubyString) dup()).succ_bang();
    }

    public IRubyObject succ_bang() {
        if (value.length() == 0) {
            return this;
        }

        boolean alnumSeen = false;
        int pos = -1;
        int c = 0;
        int n = 0;
        for (int i = value.length() - 1; i >= 0; i--) {
            c = value.get(i) & 0xFF;
            if (isAlnum(c)) {
                alnumSeen = true;
                if ((isDigit(c) && c < '9') || (isLower(c) && c < 'z') || (isUpper(c) && c < 'Z')) {
                    value.set(i, (byte)(c + 1));
                    pos = -1;
                    break;
                }
                pos = i;
                n = isDigit(c) ? '0' : (isLower(c) ? 'a' : 'A');
                value.set(i, (byte)n);
            }
        }
        if (!alnumSeen) {
            for (int i = value.length() - 1; i >= 0; i--) {
                c = value.get(i);
                if (c < 0xff) {
                    value.set(i, (byte)(c + 1));
                    pos = -1;
                    break;
                }
                pos = i;
                n = '\u0001';
                value.set(i, 0);
            }
        }
        if (pos > -1) {
            // This represents left most digit in a set of incremented
            // values?  Therefore leftmost numeric must be '1' and not '0'
            // 999 -> 1000, not 999 -> 0000.  whereas chars should be
            // zzz -> aaaa
            value.prepend((byte)(isDigit(c) ? '1' : (isLower(c) ? 'a' : 'A')));
        }
        stringMutated();
        return this;
    }

    /** rb_str_upto_m
     *
     */
    public IRubyObject upto(IRubyObject str, Block block) {
        return upto(str, false, block);
    }

    /* rb_str_upto */
    public IRubyObject upto(IRubyObject str, boolean excl, Block block) {
        // alias 'this' to 'beg' for ease of comparison with MRI
        RubyString beg = this;
        RubyString end = stringValue(str);

        int n = beg.cmp(end);
        if (n > 0 || (excl && n == 0)) {
            return beg;
        }

        RubyString afterEnd = stringValue(end.succ());
        RubyString current = beg;

        ThreadContext context = getRuntime().getCurrentContext();
        while (!current.equals(afterEnd)) {
            block.yield(context, current);
            if (!excl && current.equals(end)) {
                break;
            }

            current = (RubyString) current.succ();
            if (excl && current.equals(end)) {
                break;
            }
            if (current.length().getLongValue() > end.length().getLongValue()) {
                break;
            }
        }

        return beg;

    }


    /** rb_str_include
     *
     */
    public RubyBoolean include(IRubyObject obj) {
        if (obj instanceof RubyFixnum) {
            int c = RubyNumeric.fix2int(obj);
            for (int i = 0; i < value.length(); i++) {
                if (value.get(i) == (byte)c) {
                    return getRuntime().getTrue();
                }
            }
            return getRuntime().getFalse();
        }
        String str = stringValue(obj).toString();
        return getRuntime().newBoolean(new StringBuffer(toString()).indexOf(str) != -1);
    }

    /** rb_str_to_i
     *
     */
    public IRubyObject to_i(IRubyObject[] args) {
        long base = checkArgumentCount(args, 0, 1) == 0 ? 10 : ((RubyInteger) args[0].convertType(RubyInteger.class,
                "Integer", "to_i")).getLongValue();
        return RubyNumeric.str2inum(getRuntime(), this, (int) base);
    }

    /** rb_str_oct
     *
     */
    public IRubyObject oct() {
        if (isEmpty()) {
            return getRuntime().newFixnum(0);
        }

        int base = 8;
        String str = toString().trim();
        int pos = (str.charAt(0) == '-' || str.charAt(0) == '+') ? 1 : 0;
        if (str.indexOf("0x") == pos || str.indexOf("0X") == pos) {
            base = 16;
        } else if (str.indexOf("0b") == pos || str.indexOf("0B") == pos) {
            base = 2;
        }
        return RubyNumeric.str2inum(getRuntime(), this, base);
    }

    /** rb_str_hex
     *
     */
    public IRubyObject hex() {
        return RubyNumeric.str2inum(getRuntime(), this, 16);
    }

    /** rb_str_to_f
     *
     */
    public IRubyObject to_f() {
        return RubyNumeric.str2fnum(getRuntime(), this);
    }

    /** rb_str_split
     *
     */
    public RubyArray split(IRubyObject[] args) {
        RubyRegexp pattern;
        boolean isWhitespace = false;

        // get the pattern based on args
        if (args.length == 0) {
            isWhitespace = true;
            pattern = RubyRegexp.newRegexp(getRuntime(), "\\s+", 0, null);
        } else if (args[0] instanceof RubyRegexp) {
            // Even if we have whitespace-only explicit regexp we do not
            // mark it as whitespace.  Apparently, this is so ruby can
            // still get the do not ignore the front match behavior.
            pattern = RubyRegexp.regexpValue(args[0]);
        } else {
            String stringPattern = RubyString.stringValue(args[0]).toString();

            if (stringPattern.equals(" ")) {
                isWhitespace = true;
                pattern = RubyRegexp.newRegexp(getRuntime(), "\\s+", 0, null);
            } else {
                pattern = RubyRegexp.newRegexp(getRuntime(), RubyRegexp.escapeSpecialChars(stringPattern), 0, null);
            }
        }

        int limit = getLimit(args);
        String[] result = null;
        // attempt to convert to Unicode when appropriate
        String splitee = toString();
        boolean unicodeSuccess = false;
        if (getRuntime().getKCode() == KCode.UTF8) {
            // We're in UTF8 mode; try to convert the string to UTF8, but fall back on raw bytes if we can't decode
            // TODO: all this decoder and charset stuff could be centralized...in KCode perhaps?
            CharsetDecoder decoder = Charset.forName("UTF-8").newDecoder();
            decoder.onMalformedInput(CodingErrorAction.REPORT);
            decoder.onUnmappableCharacter(CodingErrorAction.REPORT);

            try {
                splitee = decoder.decode(ByteBuffer.wrap(value.bytes())).toString();
                unicodeSuccess = true;
            } catch (CharacterCodingException cce) {
                // ignore, just use the unencoded string
            }
        }


        if (limit == 1) {
            result = new String[] {splitee};
        } else {
            List list = new ArrayList();
            int numberOfHits = 0;
            int stringLength = splitee.length();

            Pattern pat = pattern.getPattern();
            Matcher matt = pat.matcher(splitee);

            int startOfCurrentHit = 0;
            int endOfCurrentHit = 0;
            String group = null;

            // TODO: There's a fast path in here somewhere that could just use Pattern.split

            if (matt.find()) {
                // we have matches, proceed

                // end of current hit is start of first match
                endOfCurrentHit = matt.start();

                // filter out starting whitespace matches for non-regex whitespace splits
                if (endOfCurrentHit != 0 || !isWhitespace) {
                    // not a non-regex whitespace split, proceed

                    numberOfHits++;

                    // skip first positive lookahead match
                    if (matt.end() != 0) {

                        // add the first hit
                        list.add(splitee.substring(startOfCurrentHit, endOfCurrentHit));

                        // add any matched groups found while splitting the first hit
                        for (int groupIndex = 1; groupIndex < matt.groupCount(); groupIndex++) {
                            group = matt.group(groupIndex);
                            list.add(group);
                        }
                    }
                }

                // advance start to the end of the current hit
                startOfCurrentHit = matt.end();

                // ensure we haven't exceeded the hit limit
                if (numberOfHits + 1 != limit) {
                    // loop over the remaining matches
                    while (matt.find()) {
                        // end of current hit is start of the next match
                        endOfCurrentHit = matt.start();
                        numberOfHits++;

                        // add the current hit
                        list.add(splitee.substring(startOfCurrentHit, endOfCurrentHit));

                        // add any matched groups found while splitting the current hit
                        for (int groupIndex = 1; groupIndex < matt.groupCount(); groupIndex++) {
                            group = matt.group(groupIndex);
                            list.add(group);
                        }

                        // advance start to the end of the current hit
                        startOfCurrentHit = matt.end();
                    }
                }
            }

            if (numberOfHits == 0) {
                // we found no hits, use the entire string
                list.add(splitee);
            } else if (startOfCurrentHit <= stringLength) {
                // our last match ended before the end of the string, add remainder
                list.add(splitee.substring(startOfCurrentHit, stringLength));
            }

            // Remove trailing whitespace when limit 0 is specified
            if (limit == 0 && list.size() > 0) {
                for (int size = list.size() - 1;
                size >= 0 && ((String) list.get(size)).length() == 0; size--) {
                    list.remove(size);
                }
            }

            result = (String[])list.toArray(new String[list.size()]);
        }

        // convert arraylist of strings to RubyArray of RubyStrings
        RubyArray resultArray = getRuntime().newArray(result.length);

        for (int i = 0; i < result.length; i++) {
            RubyString string = getRuntime().newString(result[i]);

            // if we're in unicode mode and successfully converted to a unicode string before,
            // make sure to keep unicode in the split values
            if (unicodeSuccess && getRuntime().getKCode() == KCode.UTF8) {
                string.setUnicodeValue(result[i]);
            }

            resultArray.append(string);
        }

        return resultArray;
    }

    private static int getLimit(IRubyObject[] args) {
        if (args.length == 2) {
            return RubyNumeric.fix2int(args[1]);
        }
        return 0;
    }

    /** rb_str_scan
     *
     */
    public IRubyObject scan(IRubyObject arg, Block block) {
        RubyRegexp pattern = RubyRegexp.regexpValue(arg);
        int start = 0;
        ThreadContext tc = getRuntime().getCurrentContext();

        // Fix for JRUBY-97: Temporary fix pending
        // decision on UTF8-based string implementation.
        // Move toString() call outside loop.
        String toString = toString();

        if (!block.isGiven()) {
            RubyArray ary = getRuntime().newArray();
            while (pattern.search(toString, start) != -1) {
                RubyMatchData md = (RubyMatchData) tc.getBackref();

                ary.append(md.getSize() == 1 ? md.group(0) : md.subseq(1, md.getSize()));

                if (md.matchEndPosition() == md.matchStartPosition()) {
                    start++;
                } else {
                    start = md.matchEndPosition();
                }

            }
            return ary;
        }

        while (pattern.search(toString, start) != -1) {
            RubyMatchData md = (RubyMatchData) tc.getBackref();

            block.yield(tc, md.getSize() == 1 ? md.group(0) : md.subseq(1, md.getSize()));

            if (md.matchEndPosition() == md.matchStartPosition()) {
                start++;
            } else {
                start = md.matchEndPosition();
            }

        }
        return this;
    }

    private IRubyObject justify(IRubyObject [] args, boolean leftJustify) {
        checkArgumentCount(args, 1, 2);
        int length = RubyNumeric.fix2int(args[0]);
        if (length <= value.length()) {
            return dup();
        }

        String paddingArg;

        if (args.length == 2) {
            paddingArg = args[1].convertToString().toString();
            if (paddingArg.length() == 0) {
                throw getRuntime().newArgumentError("zero width padding");
            }
        } else {
            paddingArg = " ";
        }

        StringBuffer sbuf = new StringBuffer(length);
        String thisStr = toString();

        if (leftJustify) {
            sbuf.append(thisStr);
        }

        // Add n whole paddings
        int whole = (length - thisStr.length()) / paddingArg.length();
        for (int w = 0; w < whole; w++ ) {
            sbuf.append(paddingArg);
        }

        // Add fractional amount of padding to make up difference
        int fractionalLength = (length - thisStr.length()) % paddingArg.length();
        if (fractionalLength > 0) {
            sbuf.append(paddingArg.substring(0, fractionalLength));
        }

        if (!leftJustify) {
            sbuf.append(thisStr);
        }

        RubyString ret = newString(sbuf.toString());

        if (args.length == 2) {
            ret.infectBy(args[1]);
        }

        return ret;
    }

    /** rb_str_ljust
     *
     */
    public IRubyObject ljust(IRubyObject [] args) {
        return justify(args, true);
    }

    /** rb_str_rjust
     *
     */
    public IRubyObject rjust(IRubyObject [] args) {
        return justify(args, false);
    }

    public IRubyObject center(IRubyObject[] args) {
        checkArgumentCount(args, 1, 2);
        int len = RubyNumeric.fix2int(args[0]);
        String pad = args.length == 2 ? args[1].convertToString().toString() : " ";
        int strLen = value.length();
        int padLen = pad.length();

        if (padLen == 0) {
            throw getRuntime().newArgumentError("zero width padding");
        }
        if (len <= strLen) {
            return dup();
        }
        StringBuffer sbuf = new StringBuffer(len);
        int lead = (len - strLen) / 2;
        for (int i = 0; i < lead; i++) {
            sbuf.append(pad.charAt(i % padLen));
        }
        sbuf.append(getValue());
        int remaining = len - (lead + strLen);
        for (int i = 0; i < remaining; i++) {
            sbuf.append(pad.charAt(i % padLen));
        }
        return newString(sbuf.toString());
    }

    public IRubyObject chop() {
        RubyString newString = (RubyString) dup();

        newString.chop_bang();

        return newString;
    }

    public IRubyObject chop_bang() {
        int end = value.length() - 1;

        if (end < 0) {
            return getRuntime().getNil();
        }

        if ((value.get(end) & 0xFF) == '\n') {
            if (end > 0 && (value.get(end-1) & 0xFF) == '\r') {
                end--;
            }
        }

        value.length(end);
        stringMutated();
        return this;
    }

    public RubyString chomp(IRubyObject[] args) {
        RubyString result = (RubyString) dup();

        result.chomp_bang(args);

        return result;
    }

    /**
     * rb_str_chomp_bang
     *
     * In the common case, removes CR and LF characters in various ways depending on the value of
     *   the optional args[0].
     * If args.length==0 removes one instance of CR, CRLF or LF from the end of the string.
     * If args.length>0 and args[0] is "\n" then same behaviour as args.length==0 .
     * If args.length>0 and args[0] is "" then removes trailing multiple LF or CRLF (but no CRs at
     *   all(!)).
     * @param args See method description.
     */
    public IRubyObject chomp_bang(IRubyObject[] args) {
        if (isEmpty()) {
            return getRuntime().getNil();
        }

        // Separator (a.k.a. $/) can be overriden by the -0 (zero) command line option
        String separator = (args.length == 0) ?
            getRuntime().getGlobalVariables().get("$/").asSymbol() : args[0].asSymbol();

        if (separator.equals(DEFAULT_RS)) {
            int end = value.length() - 1;
            int removeCount = 0;

            if (end < 0) {
                return getRuntime().getNil();
            }

            if ((value.get(end) & 0xFF) == '\n') {
                removeCount++;
                if (end > 0 && (value.get(end-1) & 0xFF) == '\r') {
                    removeCount++;
                }
            } else if ((value.get(end) & 0xFF) == '\r') {
                removeCount++;
            }

            if (removeCount == 0) {
                return getRuntime().getNil();
            }

            value.length(end - removeCount + 1);
            stringMutated();
            return this;
        }

        if (separator.length() == 0) {
            int end = value.length() - 1;
            int removeCount = 0;
            while(end - removeCount >= 0 && (value.get(end - removeCount) & 0xFF) == '\n') {
                removeCount++;
                if (end - removeCount >= 0 && (value.get(end - removeCount) & 0xFF) == '\r') {
                    removeCount++;
                }
            }
            if (removeCount == 0) {
                return getRuntime().getNil();
            }

            value.length(end - removeCount + 1);
            stringMutated();
            return this;
        }

        // Uncommon case of str.chomp!("xxx")
        if (toString().endsWith(separator)) {
            value.length(value.length() - separator.length());
            stringMutated();
            return this;
        }
        return getRuntime().getNil();
    }

    public IRubyObject lstrip() {
        return newString(getRuntime(), lstripInternal());
    }

    public ByteList lstripInternal() {
        int length = value.length();
        int i = 0;

        for (; i < length; i++) {
            if (!Character.isWhitespace(value.charAt(i))) {
                break;
            }
        }

        return new ByteList(value, i, value.length() - i);
    }

    public IRubyObject lstrip_bang() {
        ByteList newBytes = lstripInternal();
        if (value.equals(newBytes)) {
            return getRuntime().getNil();
        }
        value = newBytes;
        stringMutated();

        return this;
    }

    public IRubyObject rstrip() {
        return newString(getRuntime(), rstripInternal());
    }

    public ByteList rstripInternal() {
        int i = value.length() - 1;

        for (; i >= 0; i--) {
            if (!Character.isWhitespace(value.charAt(i))) {
                break;
            }
        }

        return new ByteList(value, 0, i + 1);
    }

    public IRubyObject rstrip_bang() {
        ByteList newBytes = rstripInternal();
        if (value.equals(newBytes)) {
            return getRuntime().getNil();
        }
        value = newBytes;
        stringMutated();

        return this;
    }

    /** rb_str_strip
     *
     */
    public IRubyObject strip() {
        if (isEmpty()) {
            return dup();
        }
        ByteList bytes = stripInternal();
        if (bytes == null) {
            return newString(getRuntime(), (ByteList)value.clone());
        }

        return newString(getRuntime(), bytes);
    }

    /** rb_str_strip_bang
     *
     */
    public IRubyObject strip_bang() {
        if (isEmpty()) {
            return getRuntime().getNil();
        }
        ByteList bytes = stripInternal();
        if (bytes == null) {
            return getRuntime().getNil();
        }
        value = bytes;
        stringMutated();
        return this;
    }

    public ByteList stripInternal() {
        int head = 0;
        while (head < value.length() && Character.isWhitespace(value.charAt(head))) head++;
        int tail = value.length() - 1;
        while (tail > head && Character.isWhitespace(value.charAt(tail))) tail--;

        if (head == 0 && tail == value.length() - 1) {
            return null;
        }

        if (head <= tail) {
            return new ByteList(value, head, tail - head + 1);
        }
        
        if (head > tail) {
            return new ByteList();
        }

        return null;
    }

    private static String expandTemplate(String spec, boolean invertOK) {
        int len = spec.length();
        if (len <= 1) {
            return spec;
        }
        StringBuffer sbuf = new StringBuffer();
        int pos = (invertOK && spec.charAt(0) == '^') ? 1 : 0;
        while (pos < len) {
            char c1 = spec.charAt(pos), c2;
            if (pos + 2 < len && spec.charAt(pos + 1) == '-') {
                if ((c2 = spec.charAt(pos + 2)) > c1) {
                    for (int i = c1; i <= c2; i++) {
                        sbuf.append((char) i);
                    }
                }
                pos += 3;
                continue;
            }
            sbuf.append(c1);
            pos++;
        }
        return sbuf.toString();
    }

    private String setupTable(String[] specs) {
        int[] table = new int[256];
        int numSets = 0;
        for (int i = 0; i < specs.length; i++) {
            String template = expandTemplate(specs[i], true);
            boolean invert = specs[i].length() > 1 && specs[i].charAt(0) == '^';
            for (int j = 0; j < 256; j++) {
                if (template.indexOf(j) != -1) {
                    table[j] += invert ? -1 : 1;
                }
            }
            numSets += invert ? 0 : 1;
        }
        StringBuffer sbuf = new StringBuffer();
        for (int k = 0; k < 256; k++) {
            if (table[k] == numSets) {
                sbuf.append((char) k);
            }
        }
        return sbuf.toString();
    }

    /** rb_str_count
     *
     */
    public IRubyObject count(IRubyObject[] args) {
        int argc = checkArgumentCount(args, 1, -1);
        String[] specs = new String[argc];
        for (int i = 0; i < argc; i++) {
            specs[i] = stringValue(args[i]).toString();
        }
        String table = setupTable(specs);

        int count = 0;
        for (int j = 0; j < value.length(); j++) {
            if (table.indexOf(value.get(j) & 0xFF) != -1) {
                count++;
            }
        }
        return getRuntime().newFixnum(count);
    }

    private ByteList getDelete(IRubyObject[] args) {
        int argc = checkArgumentCount(args, 1, -1);
        String[] specs = new String[argc];
        for (int i = 0; i < argc; i++) {
            specs[i] = stringValue(args[i]).toString();
        }
        String table = setupTable(specs);

        int strLen = value.length();
        StringBuffer sbuf = new StringBuffer(strLen);
        int c;
        for (int j = 0; j < strLen; j++) {
            c = value.get(j) & 0xFF;
            if (table.indexOf(c) == -1) {
                sbuf.append((char)c);
            }
        }
        return new ByteList(stringToBytes(sbuf.toString()));
    }

    /** rb_str_delete
     *
     */
    public IRubyObject delete(IRubyObject[] args) {
        return newString(getRuntime(), getDelete(args)).infectBy(this);
    }

    /** rb_str_delete_bang
     *
     */
    public IRubyObject delete_bang(IRubyObject[] args) {
        ByteList newStr = getDelete(args);
        if (value.equals(newStr)) {
            return getRuntime().getNil();
        }
        value = newStr;
        stringMutated();
        return this;
    }

    private ByteList getSqueeze(IRubyObject[] args) {
        int argc = args.length;
        String[] specs = null;
        if (argc > 0) {
            specs = new String[argc];
            for (int i = 0; i < argc; i++) {
                specs[i] = stringValue(args[i]).toString();
            }
        }
        String table = specs == null ? null : setupTable(specs);

        int strLen = value.length();
        if (strLen <= 1) {
            return value;
        }
        StringBuffer sbuf = new StringBuffer(strLen);
        int c1 = value.get(0) & 0xFF;
        sbuf.append((char)c1);
        int c2;
        for (int j = 1; j < strLen; j++) {
            c2 = value.get(j) & 0xFF;
            if (c2 == c1 && (table == null || table.indexOf(c2) != -1)) {
                continue;
            }
            sbuf.append((char)c2);
            c1 = c2;
        }
        return new ByteList(stringToBytes(sbuf.toString()));
    }

    /** rb_str_squeeze
     *
     */
    public IRubyObject squeeze(IRubyObject[] args) {
        return newString(getRuntime(), getSqueeze(args)).infectBy(this);
    }

    /** rb_str_squeeze_bang
     *
     */
    public IRubyObject squeeze_bang(IRubyObject[] args) {
        ByteList newStr = getSqueeze(args);
        if (value.equals(newStr)) {
            return getRuntime().getNil();
        }
        value = newStr;
        stringMutated();
        return this;
    }

    private ByteList tr(IRubyObject search, IRubyObject replace, boolean squeeze) {
        String srchSpec = search.convertToString().toString();
        String srch = expandTemplate(srchSpec, true);
        if (srchSpec.startsWith("^")) {
            StringBuffer sbuf = new StringBuffer(256);
            for (int i = 0; i < 256; i++) {
                char c = (char) i;
                if (srch.indexOf(c) == -1) {
                    sbuf.append(c);
                }
            }
            srch = sbuf.toString();
        }
        String repl = expandTemplate(replace.convertToString().toString(), false);

        int strLen = value.length();
        if (strLen == 0 || srch.length() == 0) {
            return value;
        }
        int repLen = repl.length();
        StringBuffer sbuf = new StringBuffer(strLen);
        int last = -1;
        for (int i = 0; i < strLen; i++) {
            int cs = value.get(i) & 0xFF;
            int pos = srch.indexOf(cs);
            if (pos == -1) {
                sbuf.append((char)cs);
                last = -1;
            } else if (repLen > 0) {
                char cr = repl.charAt(Math.min(pos, repLen - 1));
                if (squeeze && cr == last) {
                    continue;
                }
                sbuf.append((char)cr);
                last = cr;
            }
        }
        return new ByteList(stringToBytes(sbuf.toString()));
    }

    /** rb_str_tr
     *
     */
    public IRubyObject tr(IRubyObject search, IRubyObject replace) {
        return newString(getRuntime(), tr(search, replace, false)).infectBy(this);
    }

    /** rb_str_tr_bang
     *
     */
    public IRubyObject tr_bang(IRubyObject search, IRubyObject replace) {
        ByteList newStr = tr(search, replace, false);
        if (value.equals(newStr)) {
            return getRuntime().getNil();
        }
        value = newStr;
        stringMutated();
        return this;
    }

    /** rb_str_tr_s
     *
     */
    public IRubyObject tr_s(IRubyObject search, IRubyObject replace) {
        return newString(getRuntime(), tr(search, replace, true)).infectBy(this);
    }

    /** rb_str_tr_s_bang
     *
     */
    public IRubyObject tr_s_bang(IRubyObject search, IRubyObject replace) {
        ByteList newStr = tr(search, replace, true);
        if (value.equals(newStr)) {
            return getRuntime().getNil();
        }
        value = newStr;
        stringMutated();
        return this;
    }

    /** rb_str_each_line
     *
     */
    public IRubyObject each_line(IRubyObject[] args, Block block) {
        int strLen = value.length();
        if (strLen == 0) {
            return this;
        }
        String sep;
        if (checkArgumentCount(args, 0, 1) == 1) {
            sep = RubyRegexp.escapeSpecialChars(stringValue(args[0]).toString());
        } else {
            sep = RubyRegexp.escapeSpecialChars(getRuntime().getGlobalVariables().get("$/").asSymbol());
        }
        if (sep == null) {
            sep = "(?:\\n|\\r\\n?)";
        } else if (sep.length() == 0) {
            sep = "(?:\\n|\\r\\n?){2,}";
        }
        RubyRegexp pat = RubyRegexp.newRegexp(getRuntime(), ".*?" + sep, RubyRegexp.RE_OPTION_MULTILINE, null);
        int start = 0;
        ThreadContext tc = getRuntime().getCurrentContext();

        // Fix for JRUBY-97: Temporary fix pending
        // decision on UTF8-based string implementation.
        // Move toString() call outside loop.
        String toString = toString();

        if (pat.search(toString, start) != -1) {
            RubyMatchData md = (RubyMatchData) tc.getBackref();
            
            block.yield(tc, md.group(0));
            start = md.end(0);
            while (md.find()) {
                block.yield(tc, md.group(0));
                start = md.end(0);
            }
        }
        if (start < strLen) {
            block.yield(tc, substr(start, strLen - start));
        }
        return this;
    }

    /**
     * rb_str_each_byte
     */
    public RubyString each_byte(Block block) {
        int lLength = value.length();
        ThreadContext context = getRuntime().getCurrentContext();
        for (int i = 0; i < lLength; i++) {
            block.yield(context, getRuntime().newFixnum(value.get(i) & 0xFF));
        }
        return this;
    }

    /** rb_str_intern
     *
     */
    public RubySymbol intern() {
        String s = toString();
        if (s.equals("")) {
            throw getRuntime().newArgumentError("interning empty string");
        }
        if (s.indexOf('\0') >= 0) {
            throw getRuntime().newArgumentError("symbol string may not contain '\\0'");
        }
        return RubySymbol.newSymbol(getRuntime(), toString());
    }

    public RubySymbol to_sym() {
        return intern();
    }

    public RubyInteger sum(IRubyObject[] args) {
        long bitSize = 16;
        if (args.length > 0) {
            bitSize = ((RubyInteger) args[0].convertType(RubyInteger.class,
                    "Integer", "to_i")).getLongValue();
        }

        long result = 0;
        for (int i = 0; i < value.length(); i++) {
            result += value.get(i) & 0xFF;
        }
        return getRuntime().newFixnum(bitSize == 0 ? result : result % (long) Math.pow(2, bitSize));
    }

    public static RubyString unmarshalFrom(UnmarshalStream input) throws java.io.IOException {
        RubyString result = newString(input.getRuntime(), input.unmarshalString());
        input.registerLinkTarget(result);
        return result;
    }

    /**
     * @see org.jruby.util.Pack#unpack
     */
    public RubyArray unpack(IRubyObject obj) {
        return Pack.unpack(getRuntime(), this.value, stringValue(obj).value);
    }

    /**
     * Mutator for internal string representation.
     *
     * @param value The new java.lang.String this RubyString should encapsulate
     */
    public void setValue(CharSequence value) {
        this.value.replace(ByteList.plain(value));
        stringMutated();
    }

    public void setValue(ByteList value) {
        this.value = value;
        stringMutated();
    }

    public CharSequence getValue() {
        return toString();
    }

    public String getUnicodeValue() {
        try {
            return new String(value.bytes,0,value.realSize, "UTF8");
        } catch (Exception e) {
            throw new RuntimeException("Something's seriously broken with encodings", e);
        }
    }

    public void setUnicodeValue(String newValue) {
        try {
            value.replace(newValue.getBytes("UTF8"));
            stringMutated();
        } catch (Exception e) {
            throw new RuntimeException("Something's seriously broken with encodings", e);
        }
    }

    public byte[] getBytes() {
        return value.bytes();
    }

    public ByteList getByteList() {
        return value;
    }
}
