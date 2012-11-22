/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */
 
module skp.math.matrix;

import std.math : tan;

/*********************
 * 4x4 float matrix.
 *
 * A square matrix of size 4. Value semantic.
 */
struct SMat44 {
    private alias typeof(this) that;

    private float[16] _;

    @property {
        /*********************
         * Construct an identity matrix.
         *
         * Returns: an identy matrix
         */
        static that init() {
            that r = void;
            
            foreach (i; 0..4) {
                r[i,i] = 1.0f;
                foreach (j; (i+1)..4) 
                    r[i,j] = r[j,i] = 0.0f;
            }
            return r;
        }

        /*********************
         * Access to the pointer on subdata.
         *
         * That property can be used to access the subdata stored in
         * the matrix. It's quite useful when you want to pass the matrix
         * to a C function for instance.
         *
         * Returns: a pointer on the subdata
         */
        inout(float) * ptr() inout {
            return _.ptr;
        }

        /*********************
         * Get a transposed version of the matrix.
         *
         * Returns: a new matrix that is the transposed of the matrix the
         *          property is called on
         */
        that transposed() const {
            that r = this;

            foreach (i; 0 .. 4) {
                foreach (j; i+1 .. 4) {
                    r._[i*4 + j] = _[j*4 + i];
                    r._[j*4 + i] = _[i*4 + i];
                }
            }

            return r;
        }
    }

    /*********************
     * Equality test between two matrices (object version).
     *
     * Params:
     *     rhs = the matrix to compare
     * Returns: true if the matrices are both the same, false otherwise
     */
    bool opEquals(in that rhs) {
        return _ == rhs._;
    }

    /*********************
     * Equality test between two matrices (array version).
     *
     * Params:
     *     rhs = an array of 16 floats to compare
     * Returns: true if the matrices are both the same, false otherwise
     */
    bool opEquals(float[16] rhs) {
        return _ == rhs;
    }

    /*********************
     * Assign a matrix.
     *
     * Params:
     *     rhs = the matrix to assign
     * Returns: the matrix after it's been assigned
     */
    ref that opAssign(in that rhs) {
        _[] = rhs._[];
        return this;
    }

    /*********************
     * Assignement by multiplication operator.
     *
     * Params:
     *     rhs = the matrix to multiply by
     * Returns: the matrix after it's been multiplied by rhs
     */
    ref that opOpAssign(string O_)(in that rhs) if (O_ == "*") {
        that m = void;
        foreach (i; 0..4) {
            foreach (j; 0..4) {
                m[i,j] = 0.0f;
                foreach (k; 0..4)
                    m[i,j] += this[i,k] * rhs[k, j];
            }
        }

        this = m;
        return this;
    }
    
    /*********************
     * Random access operator.
     *
     * That operator is used to access a single element in the
     * matrix. That operator is protected against overflow fault
     * through assertions (one on i, the other on j).
     *
     * Params:
     *    i = the line index of the element
     *    j = the column index of the element
     * Returns: the indexed element
     */
    ref inout(float) opIndex(int i, int j) inout in {
        assert ( i < 4 );
        assert ( j < 4 );
    } body {
        return _[i*4+j];
    }

    /*********************
     * Multiplication operator.
     *
     * Params:
     *    rhs = the matrix to multiply by
     * Returns: the matrix * rhs
     */
    that opBinary(string O_)(in that rhs) if (O_ == "*") {
        that l = this;
        l *= rhs;
        return l;
    }
}

/* I think these unit tests are pointless. */
unittest {
    /* identity test */
    SMat44 m = SMat44.init;
    assert ( m == [
            1.0f, 0.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 1.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 1.0f
    ] );

    /* assign operator and row major */
    SMat44 m2 = m;
    m2[2,3] = 3.14f;
    assert ( m2 == [
            1.0f, 0.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 1.0f, 3.14f,
            0.0f, 0.0f, 0.0f, 1.0f
    ] );

    /* matrix inner product */
    assert ( (m * m2)  == m2 );
}
