/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */
 
module skp.math.axis;

import skp.math.vecs;

/*********************
 * Axis type aliases
 */
alias vec2_s axis2_s;
alias vec3_s axis3_s;

/*********************
 * Common X, Y and Z axis.
 */
/* FIXME */
enum axis3_s X_AXIS = axis3_s(1.0, 0.0, 0.0);
enum axis3_s Y_AXIS = axis3_s(0.0, 1.0, 0.0);
enum axis3_s Z_AXIS = axis3_s(0.0, 0.0, -1.0);
