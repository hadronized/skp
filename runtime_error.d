/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */

module skp.runtime_error;

import std.exception;

/*********************
 * Runtime error.
 *
 * That class is the base class of all exceptions.
 */
class CRuntimeError : Exception {
    this(string msg) {
        super("runtime error: " ~ msg);
    }
}
