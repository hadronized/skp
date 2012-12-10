/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */

module skp.traits;

public import std.traits;

/*********************
 * Trait that tests if a symbol has a specific feature.
 *
 * That trait can be used to test if a symbol has a specific
 * feature.
 *
 * For fow, only the "slice" feature can be tested.
 *
 * Params:
 *     T_ = symbol to test
 *     Q_ = string representing the feature
 */
template Has(T_, string Q_) if (Q_ == "slice") {
    static if (is(T_ == class) || is(T_ == struct))
        enum Has = __traits(hasMember, T_, "opSlice");
    else
        enum Has = isArray!T_;
}

/*********************
 * Trait that assumes a symbol can be used according a
 * specific concept.
 *
 * That trait lets you know if a symbol can be used a
 * special way.
 *
 * For now, only the "array" concept is available.
 *
 * Params:
 *     T_ = symbol te test
 *     Q_ = string representing the concept
 */
template Like(T_, string Q_) if (Q_ == "array") {
    enum Like = Has!(T_, "slice");
}
