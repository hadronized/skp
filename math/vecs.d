/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */

module skp.math.vecs;

import std.algorithm : map, reduce;
import skp.math.fun : sqrt;
import skp.traits;

/*********************
 * Vector.
 *
 * A vector of size N and of type D. Value semantic.
 *
 * Params:
 *     D_ = the size of the vector (2 <= D_ <= 4)
 *     T_ = the type of the stored elements
 */
struct vec_s(uint D_, T_) if (D_ >= 2 && D_ <= 4) {
    private alias typeof(this) that;

    private mixin template AddCompProperties(string N_, uint I_) {
        mixin("
            @property T_ " ~ N_ ~ "() const {
                return _[I_];
            }

            @property T_ " ~ N_ ~ "(in T_ v) {
                return _[I_] = v;
            }");
    }

    /* components */
    private T_[D_] _;

    mixin AddCompProperties!("x", 0u);
    mixin AddCompProperties!("r", 0u);
    mixin AddCompProperties!("y", 1u);
    mixin AddCompProperties!("g", 1u);
    static if (D_ > 2) {
        mixin AddCompProperties!("z", 2u);
        mixin AddCompProperties!("b", 2u);
    }
    static if (D_ > 3) {
        mixin AddCompProperties!("w", 3u);
        mixin AddCompProperties!("a", 3u);
    }

    /*********************
     * Array representation of the vector.
     *
     * That property lets you to consider the vector as a
     * regular D array.
     *
     * Returns: the D array representation of the vector
     */
    inout(T_)[D_] as_array() inout @property {
        return _;
    }

    /*********************
     * Pointer representation of the vector.
     *
     * That property lets you to consider the vector as a
     * regular D pointer. That can be useful to pass a vector
     * to a C function for instance.
     *
     * Returns: the D pointer representation of the vector
     */
    inout(T_) * ptr() inout @property {
        return _.ptr;
    }

    /*********************
     * Lenghth alias.
     */
    alias D_ length;
    /*********************
     * Value type alias.
     */
    alias T_ value_type;

    /*********************
     * Constructor.
     *
     * That constructor is variadic. You can pass it a list of
     * elements, an array, mix types such as an integer, a 2-int array
     * then an integer for a 4-int vector. The condition is that the
     * parameter type must be castable to the value type or can be
     * considered as an a array.
     *
     * Params:
     *     params = variadic parameters used to set the components
     *              of the vector
     */
    this(P...)(P params) if (params.length <= D_) {
        set_!0u(params);
    }

    /* This method recursively builds the vec */
    /* BUG: we can't use array */
    private void set_(alias I_, H_, R_...)(H_ head, R_ remaining) if (I_ <= D_) {
        static if (is(H_ : T_)) {
            /* we can directly set the corresponding component */
            _[I_] = head;
            /* and go to the next component */
            set_!(I_+1u)(remaining);
        } else {
            static if (Has!(H_, "slice")) {
                _[I_..I_+H_.length] = head[];
                set_!(I_+H_.length)(remaining);
            } else {
                static assert (0, "cannot assign " ~ H_.stringof ~ " to " ~ typeof(this).stringof);
            }
        }
    }

    /* terminal version of the set_ template method */
    private void set_(alias I_)() {
    }

    /*********************
     * Assignement operator.
     *
     * Params:
     *     rhs = something that can be passed to the constructor
     * Returns: a reference on the vector itself
     */
    ref that opAssign(A_)(in A_ rhs) {
        set_!0u(rhs);
        return this;
    }

    /*********************
     * Slice index operator.
     *
     * Params:
     *     x = start index
     *     y = end index
     * Returns: a slice of the vector
     */
    const(T_)[] opSlice(size_t x, size_t y) const {
        return _[x..y];
    }

    /*********************
     * Empty slice operator.
     *
     * That operator is useful when you want to build
     * a vector with a smaller vector and other types
     * of elements.
     
     * Returns: a slice of the whole vector
     */
    const(T_)[] opSlice() const {
        return _;
    }

    /*********************
     * Random access operator.
     *
     * That operator is used to access a single element in the
     * vector. That operator is protected against overflow fault
     * through assertion.
     */
    T_ opIndexAssign(T_ v, size_t i) in {
        assert ( i < D_ );
    } body {
        return _[i] = v;
    }

    T_ opIndex(size_t i) const in {
        assert (i < D_ );
    } body {
        return _[i];
    }

    static if (__traits(isArithmetic, T_)) {
        /*********************
         * Norm of the vector.
         *
         * Returns: the norm of the vector as a float
         */
        float norm() const @property {
            return sqrt(reduce!("a + b*b")(0.0f, _));
        }

        /*********************
         * Normalize the vector.
         *
         * Normalizes the vector, or violates an assertion if the norm
         * is equal to zero.
         */
        void normalize() {
            auto n = norm;
            assert ( n ); /* TODO: float precision-lost issue */

            foreach (ref v; _)
                v /= n;
        }

        /*********************
         * Add/sub assignement operators.
         *
         * Params:
         *     rhs = vector to add / substract
         * Returns: a reference to the vector itself after it's been
         *          added / substracted
         */
        ref that opOpAssign(string O_)(in that rhs) if (O_ == "+" || O_ == "-") {
            foreach (i; 0..D_)
                mixin("_[i] " ~ O_ ~ "= rhs._[i];");
            return this;
        }

        /*********************
         * Mult/Quot assignement operators.
         *
         * Params:
         *     v = scalar to multiply / divide by
         * Returns: a reference to the vector itself after it's been
         *          multiplied / divided by v
         * Throws: since no test on v is performed in the case of a quot, an
         *         exception can be thrown if you divide by zero
         */
        ref that opOpAssign(string O_, A_)(A_ v) if (O_ == "/" || O_ == "*") {
            foreach (ref x; _)
                mixin("x" ~ O_ ~ "= v;");
            return this;
        }

        /*********************
         * Add/sub operators.
         *
         * Params:
         *     rhs = vector to add / substract
         * Returns: the vector +/- rhs
         */
        /* TODO: we can optimize this method */
        that opBinary(string O_)(in that rhs) const if (O_ == "+" || O_ == "-") {
            that r = void;
            foreach (i; 0u..D_)
                mixin("r._[i] = _[i]" ~ O_ ~ "rhs._[i];");
            return r;
        }

        /*********************
         * Mult/Quot operators.
         *
         *
         * Params:
         *     v = scalar to multiply / divide by
         * Returns: the vector * or / rhs
         * Throws: since no test on v is performed in the case of a quot, an
         *         exception can be thrown if you divide by zero
         */
        that opBinary(string O_, S_)(S_ s) const if (O_ == "/" || O_ == "*") {
            that r = void;
            foreach (i; 0u..D_)
                mixin("r._[i] = _[i]" ~ O_ ~ " s;");
            return r;
        }

        /*********************
         * Negate operator.
         *
         * That unary operator negates the vec.
         *
         * Returns: the negated vec
         */
        that opUnary(string O_)() const if (O_ == "-") {
            import std.array : array;
            T_[D_] r = array(map!"-a"(_[]));
            return that(r);
        }

        static if (D_ == 3) {
            /*********************
             * Deprecated: use skp.math.matrix.make_trslt function instead
             */
            deprecated auto opCast(SMat44)() {
                SMat44 r;
                foreach (i; 0..D_)
                    r[i,3] = _[i];
                return r;
            }
        }
    }
}

/*********************
 * Distance function.
 *
 * Params:
 *     lhs = point a
 *     rhs = point b
 * Returns: the distance between a and b
 */
auto dist(uint D_, T_)(vec_s!(D_, T_) lhs, vec_s!(D_, T_) rhs) if (__traits(isArithmetic, T_)) {
    return (lhs - rhs).norm;
}

auto dot(uint D_, T_)(vec_s!(D_, T_) lhs, vec_s!(D_, T_) rhs) if (__traits(isArithmetic, T_)) {
    T_ r = T_.init;

    foreach (i; 0u .. D_-1)
        r += lhs[i] * rhs[i];

    return r;
}

alias vec_s!(2, float) vec2_s;
alias vec_s!(3, float) vec3_s;
alias vec_s!(4, float) vec4_s;

/*********************
 * Trait template for vectors.
 *
 * Deprecated: use the vector's own property instead
 */
deprecated template VecTrait(V_ : vec_s!(D_, T_), uint D_, T_) {
    alias D_ dimension;
    alias T_ value_type;
}
