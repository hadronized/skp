import std.algorithm;
import std.range;
import std.typecons;
import std.stdio;
import std.traits;

/*
   Pour implémenter *, il faut se demander quoi réellement faire. On a plusieurs possibilités.

   * s’applique sur un parseur. Par exemple, *l_!'a' lira le langage rationnel a*. *_ lira tout le range. *s_ lira
   des espaces jusqu’à rencontrer autre chose. Dans notre cas, il faut simplement modifier le parseur lexeme pour qu’il ne
   pop pas le caractère qui n’est pas correct.

   On doit revoir notre façon d’évaluer un parseur. L’évaluation d’un parseur peut amener à plusieurs comportements :
     * le parseur est correctement évalué, c’est à dire qu’il lit bien ce qu’il doit lire ;
     * le parseur est incorrectement évalué, c’est à dire qu’il a lu ce qu’il ne doit pas lire

   Lorsqu’un parseur est correctement évalué, il retourne quelque chose. Ce quelque chose est une représentation de ce
   qu’a lu le parseur. Par exemple le parseur « l_ » va lire un lexeme, et le retourner.
   Lorsqu’un parseur est incorrectement évalué, il retourne ce qu’il a lu juste avant de rencontrer une erreur.

   Maintenant, comment s’avoir si un parseur a été correctement évalué ? La méthode parse(range) parse le range et 
   retourne un tuple, qui a cette forme :
     Tuple!(bool, RT)
   où « RT » est le type de retour de la fonction d’évaluation portée par le parseur.

   Prenons l’exemple du super lexeme « _ », qui lit tout caractère à l’exception du délimiteur. Dans sa fonction
   d’évaluation, on va lire le caractère. Si ce caractère est un délimiteur, alors la fonction d’évaluation échoue, car
   on ne peut pas lire de délimiteur. Après toute évaluation, on pop le range tant qu’on lit un délimiteur.

   Aussi la définition d’un parseur va changer. Voici la nouvelle :

       SParser(R_, RE_, alias D_, alias E_) if (isInputRange!R_);

   où R_ est le type de range, RE_ est le type d’élément que contient le range, D_ est un tableau des délimiteurs
   statique connu à la compilation et E_ est le foncteur d’évaluation.

   Ensuite, la fonction d’évaluation fonctionne de manière simple : elle appelle le foncteur d’évaluation, récupère
   son retour (qui est un Tuple!(bool, RT)), enlève les éventuels délimiteurs en début de range, et retourne
   bêtement le tuple.

   Maintenant, on va voir comment fonctionne la boucle zéro ou plus (*).
   Cette boucle a un principe simple : elle s’applique sur un parseur, ce parseur pouvant être évalué 0 ou n fois
   correctement. Elle retourne donc un nouveau parseur dont la fonction d’évaluation est légèrement modifiée. En fait,
   ce nouveau parseur va juste lancer la fonction d’évaluation, et tant que l’évaluation est correcte, ça boucle.

   Ce nouveau parseur a bien entendu lui aussi un type, qui est un tableau dynamique du type du parseur encapsulé.
   Comme ce parseur peut-être évalué 0 on n fois, il retourne toujours true et le tableau.

   Dans tous les parseurs, la fonction d’évaluation ne peut pas être appelée si le range n’a plus d’élément. Dans ce
   cas très précis, elle doit être évaluée incorrectement.

   Maintenant, implémentons la boucle un ou plus (+).
   Cette boucle a le même principe que la boucle * à l’exception qu’au moins une évaluation doit être correcte, à
   savoir la première.

   Ok maintenant on va implémenter le séquenceur de parseurs. Un séquenceur de parseurs permet de mettre en séquence
   deux parseurs. L’idée est simple: le type de retour est un Tuple!(eval_gauche, eval_droite). Il représente la

   On va ajouter un concept important voire même indispensable : les slot-parsers. Un slot est un simple foncteur,
   qui doit pouvoir être appelé sur le retour d’une fonction d’évaluation d’un parseur. Ainsi, un slot-parser est
   un parseur qui va appeler un foncteur après une évaluation correcte du parseur dont est issu le slot-parser.

   Un nouveau concept complexe : il est possible de lancer un autre parseur lorsqu’un parseur échoue. Cette notion
   fait simplement référence à la disjonction de deux parseurs, qui dit que pour deux parseurs mis en disjonction,
   un seul parseur peut être correctement évalué. Cela implique un résultat important : si le premier parseur est
   évalué, le deuxième n’est pas appelé. Si le premier parseur n’est pas évalué, alors le deuxième doit être évalué
   pour que le retour de la disjonction soit correctement évalué. Dans le cas contraire, la disjonction des deux
   parseurs n’est pas évaluée.

   L’idée est donc simple : on prend deux parseurs p0 et p1. On évalue p0. Si il est correctement évalué, alors
   on retourne simplement son résultat. Sinon, on évalue p1. S’il est correctement évalué, on retourne son résultat,
   sinon on retourne un objet notifiant l’échec de la disjonction.

   On remarque une chose importante : en fonction du parseur qui va être évalué, le retour de la fonction d’évaluation
   va changer. Ainsi, le type de retour de la fonction d’évaluation du parseur de disjonction va être un Variant. Il
   sera soit du type de p0, soit du type de p1, soit un variant vide si la disjonction a échoué.
*/

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
