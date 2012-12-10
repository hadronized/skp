import std.algorithm;
import std.range;
import std.typecons;
import std.stdio;
import std.traits;

/* TODO: to rewrite. */

class CParseError : Throwable {
    this(string msg) {
        super("parse error: " ~ msg);
    }
}

struct SParser(R_, RE_, alias D_, alias E_) {
    auto parse(ref R_ range) {
        if (range.empty)
            return ReturnType!(E_).init;

        auto e = E_(range);
        /* left strip the eventual delimiters */
        while (!range.empty && !find(D_, range.front()).empty)
            range.popFront();
        return e;
    }

    /* slot */
    auto opIndex(S_)(S_ slot) {
        return SParser!(R_, RE_, D_, (ref R_ r) {
            auto res = parse(r);
            if (res[0])
                slot(res[1]);
            return res;
        })();
    }

    /* zero or more loop (*) */
    auto opUnary(string O_)() if (O_ == "*") {
        return SParser!(R_, RE_, D_, (ref R_ r) {
            alias ReturnType!(parse).Types[1] parse_type_t;
            parse_type_t[] res;
            
            while (1) {
                auto pres = parse(r);
                if (!pres[0])
                    break;
                res ~= pres[1];
            }

            return Tuple!(bool, parse_type_t[])(true, res);
        })();
    }

    /* one or more loop (+) */
    auto opUnary(string O_)() if (O_ == "+") {
        return SParser!(R_, RE_, D_, (ref R_ r) {
            alias ReturnType!(parse).Types[1] parse_type_t;
            parse_type_t[] res;
            bool ok = true;
            
            auto pres = parse(r);
            if (!pres[0]) {
                ok = false;
            } else {
                res ~= pres[1];
                while (1) {
                    pres = parse(r);
                    if (!pres[0])
                        break;
                    res ~= pres[1];
                }
            }

            return Tuple!(bool, parse_type_t[])(false, res);
        })();
    }

    /* sequencer */
    auto opBinary(string O_, P2_)(P2_ rhs) if (O_ == ">>") {
        return SParser!(R_, RE_, D_, (ref R_ r) => tuple(parse(r), rhs.parse(r)))();
    }
}

auto DEL = [ ' ', '\n' ];

template TParser(R_, RE_, alias D_) {
    alias SParser!(R_, RE_, D_, (ref char[] r) {
        auto c = cast(RE_)(r.front());
        auto ok = true;

        if (find(D_, c).empty) {
            r.popFront();
        } else {
            ok = false;
        }
        return Tuple!(bool, RE_)(ok, c);
    }) SSuperLexemeParser;

    template l_(RE_ C_) {
        private SParser!(R_, RE_, D_, (ref char[] r) {
            SSuperLexemeParser _;
            auto res = _.parse(r);
            if (res[0] && res[1] == C_)
                return res;
            return Tuple!(bool, ReturnType!(SSuperLexemeParser.parse).Types[1])(false, res[1]);
        }) _p;

        alias _p l_;
    }
}

TParser!(char[], char, DEL).SSuperLexemeParser _;
alias TParser!(char[], char, DEL).l_ l_;
    
int main() {
    auto str = "[ section ] field = 314 ";
    auto input = str.dup;

    writefln("input (1): [%s]", input);

    void section_name(in char[] n) {
        writefln("section: %s", n);
    }

    void field_name(in char[] n) {
        writefln("field: %s", n);
    }

    void value(in char[] n) {
        writefln("value: %s", n);
    }

    auto parser = l_!'[' >> (*_)[&section_name] >> l_!']' >> (*_)[&field_name] >> l_!'=' >> (*_)[&value];
    auto res = parser.parse(input);

    writefln("result: [%s]", res);
    writefln("input (2): [%s]", input);

    return 0;
}
