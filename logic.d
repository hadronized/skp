/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */

module skp.logic;

import skp.log;

version ( none ) {
class CRun : CCompositeLogic {
    bool ran;

    this(IBootstrap boot) {
        auto l = boot.logics(this);
        log(ELog.DEBUG, "installing %d logics from the bootstrap in the run logic", l.length);
        logics = l;
        ran = false;
    }

    override bool run() {
        ran = true;

        log(ELog.DEBUG, "running the application");
        while (ran)
            super.run();
        log(ELog.DEBUG, "application ended");
        return true;
    }
}
}

/*********************
 * Application run logic.
 *
 * That logic is the logic to call to run the application.
 * Its responsibility is quite simple: initialize the
 * application's bootstrap, and loop around the run of
 * the bootstrap. If the bootstrap run function returns
 * false, the application ends.
 *
 * The bootstrap may be anything that owns the below
 * public function:
 *     bool init(CRun)
 *
 * Bugs: up to know, there's no support of return code
 *       of the bootstrap run function
 */
class CRun {
    bool ran;

    this() {
        ran = false;
    }

    int run(__Bootstrap)() {
        static if(!is(__Bootstrap))
            static assert (0, "no bootstrap class given");
        ran = true;

        log(ELog.DEBUG, "initializing the bootstrap");
        auto boot = new __Bootstrap;
        boot.init(this);

        log(ELog.DEBUG, "running the application");
        while (ran) {
            if (!boot.run())
                break;
        }
        log(ELog.DEBUG, "application ended");
        return 0;
    }
}
