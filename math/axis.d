/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */
 
module skp.math.axis;

import skp.math.vecs;

/*********************
 * Axis type aliases
 */
alias SVec2 SAxis2;
alias SVec3 SAxis3;

/*********************
 * Common X, Y and Z axis.
 */
enum SAxis3 X_AXIS = SAxis3(1.0, 0.0, 0.0);
enum SAxis3 Y_AXIS = SAxis3(0.0, 1.0, 0.0);
enum SAxis3 Z_AXIS = SAxis3(0.0, 0.0, -1.0);