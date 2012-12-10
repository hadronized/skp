/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */

module skp.log;

import std.stdio;
import std.datetime;
import std.format;

/*********************
 * Log flag.
 *
 * That flag is a bitfields describing what
 * piece of the logger is enabled. For instance,
 * you can disable any output of the logger by
 * setting that flag to log_e.NONE. If you want
 * it to output only debug information, set it
 * to log_e.DEBUG. Debug and errors only: set it
 * to log_e.DEBUG | Elog.ERROR; and so on.
 */
char skp_logflag;

/*********************
 * Possible logger flag.
 *
 * That enum gathers all constants you can use
 * to specify what part of the logger you want
 * to turn on or to log to specific parts of it.
 */
enum log_e {
    NONE    = 0x00,
    ALL     = 0xFF,
    DEBUG   = 0x01,
    WARNING = 0x02,
    ERROR   = 0x04,
    LOG     = 0x08
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
 * log(log_e.DEBUG, "this is written as a debug message");
 * log(log_e.WARNING, "this is a warning message");
 * log(log_e.DEBUG | log_e.ERROR, "this message is output twice as a debug and error message");
 * ----------
 */

void log(A...)(log_e flag, lazy A msg) {
    if (skp_logflag == log_e.NONE)
        return;
        
    auto time = cast(DateTime)Clock.currTime();
    auto t = time.toSimpleString() ~ " | ";

    if (skp_logflag & log_e.DEBUG & flag) {
        writef("%sdebug: ", t);
        writefln(msg);
    }
    if (skp_logflag & log_e.WARNING & flag) {
        writef("%swarning: ", t);
        writefln(msg);
    }
    if (skp_logflag & log_e.ERROR & flag) {
        stderr.writef("%serror: ", t);
        writefln(msg);
    }
    if (skp_logflag & log_e.LOG & flag) {
        write(t);
        writefln(msg);
    }
}
