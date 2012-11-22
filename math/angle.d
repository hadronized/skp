/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */
module skp.math.angle;

import std.math : PI;

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
pure rad_t deg2rad(deg_t d){
    return d*PI/180;
}

/*********************
 * Converts radians into degrees.
 *
 * Params:
 *     r = radians to convert into degrees
 */
pure deg_t rad2deg(rad_t r) {
    return r*180/PI;
}