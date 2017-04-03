var _JsArray_empty = [];

function _JsArray_singleton(val)
{
    return [val];
}

function _JsArray_length(arr)
{
    return arr.length;
}

var _JsArray_initialize = F3(function(size, offset, f)
{
    var result = _JsArray_newArray(size);

    for (var i = 0; i < size; i++) {
        result[i] = f(offset + i);
    }

    return result;
});

function _JsArray_newArray(size)
{
    // A JS literal is much faster than `new Array(size)` in Safari.
    // The following code optimizes the common case of 32-sized arrays,
    // while falling back to the "proper" way to preallocate arrays
    // for other sizes. This makes a big performance difference in
    // Safari, while exerting a minor performance hit in Chrome.
    // For 32-sized arrays, Chrome and Safari become equally fast.
    if (size !== 32) {
        return new Array(size);
    }

    return [
        null, null, null, null, null,
        null, null, null, null, null,
        null, null, null, null, null,
        null, null, null, null, null,
        null, null, null, null, null,
        null, null, null, null, null,
        null, null
    ];
}

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = _JsArray_newArray(max);

    for (var i = 0; i < max; i++) {
        if (ls.ctor === '[]') {
            result.length = i;
            break;
        }

        result[i] = ls._0;
        ls = ls._1;
    }

    return {
        ctor: '_Tuple2',
        _0: result,
        _1: ls
    };
});

var _JsArray_unsafeGet = F2(function(idx, arr)
{
    return arr[idx];
});

var _JsArray_unsafeSet = F3(function(idx, val, arr)
{
    var result = arr.slice();
    result[idx] = val;
    return result;
});

var _JsArray_push = F2(function(val, arr)
{
    var result = arr.slice();
    result.push(val);
    return result;
});

var _JsArray_foldl = F3(function(f, init, arr)
{
    var acc = init;
    var len = arr.length;

    for (var i = 0; i < len; i++) {
        acc = A2(f, arr[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(f, init, arr)
{
    var acc = init;

    for (var i = arr.length - 1; i >= 0; i--) {
        acc = A2(f, arr[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(f, arr)
{
    var len = arr.length;
    var result = _JsArray_newArray(len);

    for (var i = 0; i < len; i++) {
        result[i] = f(arr[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(f, offset, arr)
{
    var len = arr.length;
    var result = _JsArray_newArray(len);

    for (var i = 0; i < len; i++) {
        result[i] = A2(f, offset + i, arr[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, arr)
{
    return arr.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length) {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = _JsArray_newArray(size);

    for (var i = 0; i < destLen; i++) {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++) {
        result[i + destLen] = source[i];
    }

    return result;
});
