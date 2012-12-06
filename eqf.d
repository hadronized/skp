/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */

module skp.eqf;

/*********************
 * Float comparison.
 *
 * That function compares two floats and returns true if they are
 * equals to each other regarding the given epsilon value.
 *
 * Params:
 *     a = float value
 *     b = float value
 *     e = epsilon error
 */
bool eqf(float a, float b, float e = 0.000_001f) {
    auto diff = a - b;   
    return diff < .0f ? (-diff < e) : (diff < e);
}

unittest {
    assert ( eqf(3.14f + 6.9826f, 10.1226) );
    assert ( eqf(.0f, .0f) );
    assert ( !eqf(1.0f, 2.0f) );
}