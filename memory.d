/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */
 
module skp.memory;

version ( none ) {
auto inst(T_, A...)(A args) {
    auto p = new T_(args);

    static if (is(T_ : Object))
        return s_ptr!T_(&p);
    else
        return s_ptr!T_(p);
}

struct w_ptr(T_) {
    alias T_* ptr_t;
    private alias typeof(this) that;

    ptr_t _;

    this(ptr_t p) {
        _ = p;
    }

    T opUnary(string O_)() if (O_ == "*") {
        assert ( _ );
        return *_;
    }
}

struct s_ptr(T_) {
    alias T_* ptr_t;
    private alias typeof(this) that;

    private {
        int *_pCount;
        ptr_t _;
    }

    invariant() {
        assert ( _pCount );
    }
    
    this(ptr_t p) {
        _ = p;
        _pCount = new int;
        ++(*_pCount);
    }

    this(this) {
        ++(*_pCount);
    }

    ~this() {
        --(*_pCount);
        if (*_pCount == 0) 
            clear(_pCount);
    }

    @property {
        int count() {
            return *_pCount;
        }

        auto weak() {
            return w_ptr!T_(_);
        }
    }
}
}

import core.exception;
import core.memory : GC;
import std.c.stdlib;
import skp.log;
/*********************
 * Tracked allocation mixin template.
 *
 * That mixin template can be used to track allocation in the
 * logger.
 */
mixin template MTTrackedAllocation {
    new(size_t s) {
        auto p = std.c.stdlib.malloc(s);
        if (!p)
            throw new OutOfMemoryError();
        GC.addRange(p, s);
        log(ELog.DEBUG, "allocated %d bytes at 0x%x for instance of %s", s, p, this);
        return p;
    }
    
    delete(void *p) {
        if (!p) {
            GC.removeRange(p);
            std.c.stdlib.free(p);
            log(ELog.DEBUG, "deallocated 0x%x", p);
        }
    }