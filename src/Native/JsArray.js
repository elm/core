// import Maybe

var _elm_lang$core$Native_JsArray = function() {
/* A thin, but still immutable, wrapper over native Javascript arrays. */

// An empty array
var empty = {
    ctor: 'JsArray',
    _0: []
};

function singleton(val) {
    return {
        ctor: 'JsArray',
        _0: [val]
    };
}

function length(arr) {
    return arr._0.length;
}

function get(idx, arr) {
    var val = arr._0[idx];
    if (val) {
        return _elm_lang$core$Maybe$Just(val);
    }

    return _elm_lang$core$Maybe$Nothing;
}

function set(idx, val, arr) {
    var copy = arr._0.slice();
    copy[idx] = val;
    return {
        ctor: 'JsArray',
        _0: copy
    };
}

function push(val, arr) {
    var copy = arr._0.slice();
    copy.push(val);
    return {
        ctor: 'JsArray',
        _0: copy
    };
}

function foldl(f, init, arr) {
    var a = init,
        len = length(arr),
        i;

    for (i = 0; i < len; i++) {
        a = A2(f, arr._0[i], a);
    }

    return a;
}

function foldr(f, init, arr) {
    var a = init,
        i;

    for (i = length(arr) - 1; i >= 0; i--) {
        a = A2(f, arr._0[i], a);
    }

    return a;
}

return {
    empty: empty,
    singleton: singleton,
    length: length,
    get: F2(get),
    set: F3(set),
    push: F2(push),
    foldl: F3(foldl),
    foldr: F3(foldr)
};

}();