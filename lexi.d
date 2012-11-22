import std.range;
import std.typecons;
import std.stdio;
import std.traits;

/*
   Pour implémenter *, il faut se demander quoi réellement faire. On a plusieurs possibilités.

   * s’applique sur un parseur. Par exemple, *l_!'a' lira le langage rationnel a*. *_ lira tout le range. *s_ lira
   des espaces jusqu’à rencontrer autre chose. Dans notre cas, il faut simplement modifier le parseur lexeme pour qu’il ne
   pop pas le caractère qui n’est pas correct.
*/

class CParseError : Throwable {
    this(string msg) {
        super("parse error: " ~ msg);
    }
}

struct SParser(R_, alias D_, alias Eval_) if (isInputRange!R_) {
    auto eval(ref R_ range) {
        if (range.empty)
            throw new CParseError("reached EOI");
        return Eval_(range);
    }

    /* sequencer */
    auto opBinary(string O_, P2_) (P2_ rhs) if (O_ == ">>") {
        return SParser!(R_, (ref R_ range) => tuple(eval(range), rhs.eval(range)))();
    }

    /* zero or more loop */
    auto opUnary(string O_)() if (O_ == "*") {
        return SParser!(R_, (ref R_ range) {
            alias ReturnType!eval[] RT;

            RT r;
            try {
                while (1) {
                    if (range.empty)
                        break;
                    r ~= eval(range);
                }
            } catch (const CParseError e) {
            }

            return r;
        })();
    }
    
    /* one or more loop */
    auto opUnary(string O_)() if (O_ == "+") {
        return SParser!(R_, (ref R_ range) {
            alias ReturnType!eval[] RT;

            RT r;
            r ~= eval(range);
            try {
                while (1) {
                    if (range.empty)
                        break;
                    r ~= eval(range);
                }
            } catch (const CParseError e) {
            }

            return r;
        })();
    }

    /* slot */
    auto opIndex(S_)(S_ slot) {
        return SParser!(R_, (ref R_ range) {
            auto r = eval(range);
            slot(r);
            return r;
        })();
    }
}

/* a parser that reads any single char */
alias SParser!(char[], (ref char[] range) {
    auto c = range.front();
    range.popFront();
    return c;
}) SCharParser;

/* a parser that reads a specific char */
template l_(char C_) {
    private SParser!(char[], (ref char[] range) {
        auto c = range.front();

        if (c != C_)
            throw new CParseError("read '" ~ cast(char)c ~ "' while expecting '" ~ C_ ~ "'");
        range.popFront();
        return c;
    }) _p;

    alias _p l_;
}

/* default char parser */
SCharParser _;
/* space */
alias l_!' ' s_;

int main() {
    auto str = "    test  ";
    auto input = str.dup;

    void foo(dchar c) {
        writefln("read %c", c);
    }

    void bar(Tuple!(dchar, dchar) p) {
        writefln("--> %s", p);
    }

    auto parser = *s_ >> +_ >> *s_;

    auto r = parser.eval(input);
    writefln("result: [%s]", r);
    writefln("input: %s", input);
    return 0;
}
