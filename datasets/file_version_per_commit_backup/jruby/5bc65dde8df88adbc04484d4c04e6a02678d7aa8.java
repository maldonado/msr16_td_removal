/***** BEGIN LICENSE BLOCK *****
 * Version: EPL 1.0/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Eclipse Public
 * License Version 1.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.eclipse.org/legal/epl-v10.html
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * Copyright (C) 2004 Jan Arne Petersen <jpetersen@uni-bonn.de>
 * 
 * Alternatively, the contents of this file may be used under the terms of
 * either of the GNU General Public License Version 2 or later (the "GPL"),
 * or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the EPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the EPL, the GPL or the LGPL.
 ***** END LICENSE BLOCK *****/
package org.jruby.lexer.yacc;

import java.io.IOException;
import org.jcodings.Encoding;
import org.jruby.ast.RegexpNode;
import org.jruby.lexer.yacc.SyntaxException.PID;
import org.jruby.parser.Tokens;
import org.jruby.util.ByteList;
import org.jruby.util.KCode;
import org.jruby.util.RegexpOptions;

public class StringTerm extends StrTerm {
    // Expand variables, Indentation of final marker
    private int flags;

    // Start of string ([, (, {, <, ', ", \n) 
    private final char begin;

    // End of string (], ), }, >, ', ", \0)
    private final char end;

    // How many strings are nested in the current string term
    private int nest;

    public StringTerm(int flags, int begin, int end) {
        this.flags = flags;
        this.begin = (char) begin;
        this.end   = (char) end;
        this.nest  = 0;
    }

    protected ByteList createByteList(RubyLexer lexer) {
        return new ByteList(new byte[]{}, lexer.getEncoding());
    }

    private int endFound(RubyLexer lexer, LexerSource src) throws IOException {
            if ((flags & RubyLexer.STR_FUNC_QWORDS) != 0) {
                flags = -1;
                lexer.getPosition();
                return ' ';
            }

            if ((flags & RubyLexer.STR_FUNC_REGEXP) != 0) {
                RegexpOptions options = parseRegexpFlags(lexer, src);
                ByteList regexpBytelist = ByteList.create("");

                lexer.setValue(new RegexpNode(src.getPosition(), regexpBytelist, options));
                return Tokens.tREGEXP_END;
            }

            lexer.setValue("\"");
            return Tokens.tSTRING_END;
    }

    // Return of 0 means failed to find anything.  Non-zero means return that from lexer.
    private int parsePeekVariableName(RubyLexer lexer, LexerSource src) throws IOException {
        int c = src.read(); // byte right after #
        int significant = -1;
        switch (c) {
            case '$': {  // we unread back to before the $ so next lex can read $foo
                int c2 = src.read();

                if (c2 == '-') {
                    int c3 = src.read();

                    if (c3 == RubyLexer.EOF) {
                        src.unread(c3); src.unread(c2);
                        return 0;
                    }

                    significant = c3;                              // $-0 potentially
                    src.unread(c3); src.unread(c2);
                    break;
                } else if (lexer.isGlobalCharPunct(c2)) {          // $_ potentially
                    lexer.setValue("#" + c2);

                    src.unread(c2); src.unread(c);
                    return Tokens.tSTRING_DVAR;
                }

                significant = c2;                                  // $FOO potentially
                src.unread(c2);
                break;
            }
            case '@': {  // we unread back to before the @ so next lex can read @foo
                int c2 = src.read();

                if (c2 == '@') {
                    int c3 = src.read();

                    if (c3 == RubyLexer.EOF) {
                        src.unread(c3); src.unread(c2);
                        return 0;
                    }

                    significant = c3;                                // #@@foo potentially
                    src.unread(c3); src.unread(c2);
                    break;
                }

                significant = c2;                                    // #@foo potentially
                src.unread(c2);
                break;
            }
            case '{':
                lexer.setValue("#" + c);
                return Tokens.tSTRING_DBEG;
            default:
                // We did not find significant char after # so push it back to
                // be processed as an ordinary string.
                src.unread(c);
                return 0;
        }

        if (significant != -1 && Character.isAlphabetic(significant) || significant == '_') {
            src.unread(c);
            lexer.setValue("#" + significant);
            return Tokens.tSTRING_DVAR;
        }

        return 0;
    }

    public int parseString(RubyLexer lexer, LexerSource src) throws IOException {
        boolean spaceSeen = false;
        int c;

        // FIXME: How much more obtuse can this be?
        // Heredoc already parsed this and saved string...Do not parse..just return
        if (flags == -1) {
            lexer.setValue("\"");
            return Tokens.tSTRING_END;
        }

        c = src.read();
        if ((flags & RubyLexer.STR_FUNC_QWORDS) != 0 && Character.isWhitespace(c)) {
            do { c = src.read(); } while (Character.isWhitespace(c));
            spaceSeen = true;
        }

        if (c == end && nest == 0) return endFound(lexer, src);
        
        if (spaceSeen) {
            src.unread(c);
            lexer.getPosition();
            return ' ';
        }
        
        ByteList buffer = createByteList(lexer);
        lexer.newtok();
        if ((flags & RubyLexer.STR_FUNC_EXPAND) != 0 && c == '#') {
            int token = parsePeekVariableName(lexer, src);

            if (token != 0) return token;
        }
        src.unread(c);
        
        if (parseStringIntoBuffer(lexer, src, buffer) == RubyLexer.EOF) {
            throw new SyntaxException(PID.STRING_HITS_EOF, src.getPosition(),
                    src.getCurrentLine(), "unterminated string meets end of file");
        }

        lexer.setValue(lexer.createStrNode(lexer.getPosition(), buffer, flags));
        return Tokens.tSTRING_CONTENT;
    }

    private RegexpOptions parseRegexpFlags(RubyLexer lexer, LexerSource src) throws IOException {
        RegexpOptions options = new RegexpOptions();
        int c;
        StringBuilder unknownFlags = new StringBuilder(10);

        lexer.newtok();
        for (c = src.read(); c != RubyLexer.EOF
                && Character.isLetter(c); c = src.read()) {
            switch (c) {
            case 'i':
                options.setIgnorecase(true);
                break;
            case 'x':
                options.setExtended(true);
                break;
            case 'm':
                options.setMultiline(true);
                break;
            case 'o':
                options.setOnce(true);
                break;
            case 'n':
                options.setExplicitKCode(KCode.NONE);
                break;
            case 'e':
                options.setExplicitKCode(KCode.EUC);
                break;
            case 's':
                options.setExplicitKCode(KCode.SJIS);
                break;
            case 'u':
                options.setExplicitKCode(KCode.UTF8);
                break;
            case 'j':
                options.setJava(true);
                break;
            default:
                unknownFlags.append((char) c);
                break;
            }
        }
        src.unread(c);
        if (unknownFlags.length() != 0) {
            throw new SyntaxException(PID.REGEXP_UNKNOWN_OPTION, src.getPosition(), "unknown regexp option"
                    + (unknownFlags.length() > 1 ? "s" : "") + " - "
                    + unknownFlags.toString(), unknownFlags.toString());
        }
        return options;
    }

    private void mixedEscape(RubyLexer lexer, Encoding foundEncoding, Encoding parserEncoding) {
        throw new SyntaxException(PID.MIXED_ENCODING,lexer.getPosition(), "",
                foundEncoding + " mixed within " + parserEncoding);
    }

    // mri: parser_tokadd_string
    public int parseStringIntoBuffer(RubyLexer lexer, LexerSource src, ByteList buffer) throws IOException {
        boolean qwords = (flags & RubyLexer.STR_FUNC_QWORDS) != 0;
        boolean expand = (flags & RubyLexer.STR_FUNC_EXPAND) != 0;
        boolean escape = (flags & RubyLexer.STR_FUNC_ESCAPE) != 0;
        boolean regexp = (flags & RubyLexer.STR_FUNC_REGEXP) != 0;
        boolean symbol = (flags & RubyLexer.STR_FUNC_SYMBOL) != 0;
        boolean hasNonAscii = false;
        int c;
        Encoding encoding = lexer.getEncoding();

        while ((c = src.read()) != RubyLexer.EOF) {
            if (begin != '\0' && c == begin) {
                nest++;
            } else if (c == end) {
                if (nest == 0) {
                    src.unread(c);
                    break;
                }
                nest--;
            } else if (expand && c == '#' && !src.peek('\n')) {
                int c2 = src.read();

                if (c2 == '$' || c2 == '@' || c2 == '{') {
                    src.unread(c2);
                    src.unread(c);
                    break;
                }
                src.unread(c2);
            } else if (c == '\\') {
                c = src.read();
                switch (c) {
                case '\n':
                    if (qwords) break;
                    if (expand) continue;
                    buffer.append('\\');
                    break;

                case '\\':
                    if (escape) buffer.append(c);
                    break;

                case 'u':
                    if (!expand) {
                        buffer.append('\\');
                        break;
                    }

                    if (regexp) {
                        lexer.readUTFEscapeRegexpLiteral(buffer);
                    } else {
                        lexer.readUTFEscape(buffer, true, symbol);
                    }

                    if (hasNonAscii && buffer.getEncoding() != encoding) {
                        mixedEscape(lexer, buffer.getEncoding(), encoding);
                    }

                    continue;
                default:
                    if (regexp) {
                        src.unread(c);
                        parseEscapeIntoBuffer(lexer, encoding, src, buffer);

                        if (hasNonAscii && buffer.getEncoding() != encoding) {
                            mixedEscape(lexer, buffer.getEncoding(), encoding);
                        }
                        
                        continue;
                    } else if (expand) {
                        src.unread(c);
                        if (escape) buffer.append('\\');
                        c = lexer.readEscape();
                    } else if (qwords && Character.isWhitespace(c)) {
                        /* ignore backslashed spaces in %w */
                    } else if (c != end && !(begin != '\0' && c == begin)) {
                        buffer.append('\\');
                    }
                }
            } else if (!Encoding.isAscii((byte) c)) {
                if (buffer.getEncoding() != encoding) {
                    mixedEscape(lexer, buffer.getEncoding(), encoding);
                }
                
                if (addNonAsciiToBuffer(c, src, encoding, lexer, buffer) == RubyLexer.EOF) return RubyLexer.EOF;

                continue;
            } else if (qwords && Character.isWhitespace(c)) {
                src.unread(c);
                break;
            }

            // Hmm did they change this?
/*          if (c == '\0' && symbol) {
                throw new SyntaxException(PID.NUL_IN_SYMBOL, lexer.getPosition(),
                        src.getCurrentLine(), "symbol cannot contain '\\0'");
            } else*/ if ((c & 0x80) != 0) {
                hasNonAscii = true;
                if (buffer.getEncoding() != encoding) {
                    mixedEscape(lexer, buffer.getEncoding(), encoding);
                }
            }
            buffer.append(c);
        }
        
        return c;
    }

    // Was a goto in original ruby lexer
    private void escaped(RubyLexer lexer, Encoding encoding, LexerSource src, ByteList buffer) throws java.io.IOException {
        int c;

        switch (c = src.read()) {
        case '\\':
            parseEscapeIntoBuffer(lexer, encoding, src, buffer);
            break;
        case RubyLexer.EOF:
            throw new SyntaxException(PID.INVALID_ESCAPE_SYNTAX, src.getPosition(),
                    src.getCurrentLine(), "Invalid escape character syntax");
        default:
            buffer.append(c);
        }
    }

    private void parseEscapeIntoBuffer(RubyLexer lexer, Encoding encoding, LexerSource src, ByteList buffer) throws java.io.IOException {
        int c;

        switch (c = src.read()) {
        case '\n':
            break; /* just ignore */
        case '0':
        case '1':
        case '2':
        case '3': /* octal constant */
        case '4':
        case '5':
        case '6':
        case '7':
            buffer.append('\\');
            buffer.append(c);
            for (int i = 0; i < 2; i++) {
                c = src.read();
                if (c == RubyLexer.EOF) {
                    throw new SyntaxException(PID.INVALID_ESCAPE_SYNTAX, src.getPosition(),
                            src.getCurrentLine(), "Invalid escape character syntax");
                }
                if (!RubyLexer.isOctChar(c)) {
                    src.unread(c);
                    break;
                }
                buffer.append(c);
            }
            break;
        case 'x': /* hex constant */
            buffer.append('\\');
            buffer.append(c);
            c = src.read();
            if (!RubyLexer.isHexChar(c)) {
                throw new SyntaxException(PID.INVALID_ESCAPE_SYNTAX, src.getPosition(),
                        src.getCurrentLine(), "Invalid escape character syntax");
            }
            buffer.append(c);
            c = src.read();
            if (RubyLexer.isHexChar(c)) {
                buffer.append(c);
            } else {
                src.unread(c);
            }
            break;
        case 'M':
            if ((c = src.read()) != '-') {
                throw new SyntaxException(PID.INVALID_ESCAPE_SYNTAX, src.getPosition(),
                        src.getCurrentLine(), "Invalid escape character syntax");
            }
            buffer.append(new byte[] { '\\', 'M', '-' });
            escaped(lexer, encoding, src, buffer);
            break;
        case 'C':
            if ((c = src.read()) != '-') {
                throw new SyntaxException(PID.INVALID_ESCAPE_SYNTAX, src.getPosition(),
                        src.getCurrentLine(), "Invalid escape character syntax");
            }
            buffer.append(new byte[] { '\\', 'C', '-' });
            escaped(lexer, encoding, src, buffer);
            break;
        case 'c':
            buffer.append(new byte[] { '\\', 'c' });
            escaped(lexer, encoding, src, buffer);
            break;
        case RubyLexer.EOF:
            throw new SyntaxException(PID.INVALID_ESCAPE_SYNTAX, src.getPosition(),
                    src.getCurrentLine(), "Invalid escape character syntax");
        default:
            if (!Encoding.isAscii((byte) c)) {
                addNonAsciiToBuffer(c, src, encoding, lexer, buffer);
            } else {
                if (c != '\\' || c != end) buffer.append('\\');

                buffer.append(c);
            }
        }
    }

    private int addNonAsciiToBuffer(int c, LexerSource src, Encoding encoding, RubyLexer lexer, ByteList buffer) throws SyntaxException, IOException {
        c = src.readCodepoint(c, encoding);

        if (c == -2) { // FIXME: Hack
            throw new SyntaxException(PID.INVALID_MULTIBYTE_CHAR, lexer.getPosition(),
                    null, "invalid multibyte char (" + encoding + ")");
        }

        // FIXME: We basically go from bytes to codepoint back to bytes to append them...fix this
        return lexer.tokenAddMBC(c, buffer);
    }
}
