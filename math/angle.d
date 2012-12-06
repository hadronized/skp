/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */
module skp.math.angle;

static import std.math;

/*********************
 * PI.
 *
 * Note: becareful! The std.math.PI constant is real while
 * it's float in skp.math.angle!
 */
enum PI = cast(float)(std.math.PI);
 
/*********************
 * Angle type aliases.
 */
alias float deg_t;
/** ditto */
alias float rad_t;

/*********************
 * Converts degrees into radians.
 *
 * Params:
 *     d = degrees to convert into radians
 */
rad_t deg2rad(deg_t d) pure nothrow {
    return d*PI/180.0f;
}

/*********************
 * Converts radians into degrees.
 *
 * Params:
 *     r = radians to convert into degrees
 */
deg_t rad2deg(rad_t r) pure nothrow {
    return r*180.0f/PI;
}

 unittest {
    import skp.eqf;
    assert ( eqf(rad2deg(PI), 180.0f) );
    assert ( eqf(rad2deg(PI), 180.0f) );
    assert ( eqf(deg2rad(180.0f), PI) );
    assert ( eqf(rad2deg(PI/2), 90.0f) );
    assert ( eqf(deg2rad(45.0f), PI/4) );
    assert ( eqf(rad2deg(2*PI), 360.0f) );
}
