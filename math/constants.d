/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */

module skp.math.constants;

public import skp.math.fun : sqrt;

/*********************
 * The Golden ratio constant.
 *
 * The Golden ratio is a math constant used to construct golden object.
 * The Golden ratio is (1 + sqrt(5)) / 2.
 */
enum GOLDEN_RATIO = cast(float)((1.0f + sqrt(5.0f))/2);
