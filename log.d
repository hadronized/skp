/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */

module skp.log;

import std.stdio : write, writefln;
import std.datetime;
import std.format;

/*********************
 * Log flag.
 *
 * That flag is a bitfields describing what
 * piece of the logger is enabled. For instance,
 * you can disable any output of the logger by
 * setting that flag to ELog.NONE. If you want
 * it to output only debug information, set it
 * to ELog.DEBUG. Debug and errors only: set it
 * to ELog.DEBUG | Elog.ERROR; and so on.
 */
char skp_logflag;

/*********************
 * Possible logger flag.
 *
 * That enum gathers all constants you can use
 * to specify what part of the logger you want
 * to turn on or to log to specific parts of it.
 */
enum ELog {
    NONE    = 0x00,
    DEBUG   = 0x01,
    WARNING = 0x02,
    ERROR   = 0x04,
    ALL     = 0x07
}

/*********************
 * Logger.
 *
 * The logger is a simple function you can use
 * the same way you use writefln, expect that
 * the first argument is the parts of the logger
 * to use to log the message.
 *
 * Params:
 *     flag = the logger parts to use
 *     msg = the message to log
 *
 * Examples:
 * ----------
 * log(ELog.DEBUG, "this is written as a debug message");
 * log(ELog.WARNING, "this is a warning message");
 * log(ELog.DEBUG | ELog.ERROR, "this message is output twice as a debug and error message");
 * ----------
 */

void log(A...)(ELog flag, A msg) {
    auto time = cast(DateTime)Clock.currTime();
    auto t = time.toSimpleString() ~ " | ";

    if (skp_logflag == ELog.NONE)
        return;
    if (skp_logflag & ELog.DEBUG & flag) {
        write(t);
        writefln(msg);
    }
    if (skp_logflag & ELog.WARNING & flag) {
        write(t ~ "warning: ");
        writefln(msg);
    }
    if (skp_logflag & ELog.ERROR & flag) {
        write(t ~ "error: ");
        writefln(msg);
    }
}
