/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */
 
module skp.clock;

import core.time;
import skp.log;

/*********************
 * Clock.
 *
 * A clock used to count elapsed time. You can specify when
 * the clock counts, and at anytime you can get the elapsed
 * time.
 */
class clock_c {
    private TickDuration _start;

    /*********************
     * Constructor.
     *
     * Constructs the clock and starts to count.
     */
    this() {
        reset();
    }

    /*********************
     * Reset the clock.
     *
     * Resets the clock; it now counts from the moment you call reset.
     */
    void reset() {
        _start = _start.currSystemTick;
        log(ELog.DEBUG, "restarted clock 0x%x", &this);
    }

    /*********************
     * Get the elapsed time.
     *
     * Params:
     *     N_ = the unit of the result ("msecs";"usecs";etc.)
     * Results: the elapsed time according the N_ unit
     */
    @property auto opDispatch(string N_)() {
        mixin("return (_start.currSystemTick - _start)." ~ N_ ~ ";");
    }
}
