module skp.memory;

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
