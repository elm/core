/*

import Elm.Kernel.Utils exposing (Tuple2)

*/


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
    var result = new Array(size);

    for (var i = 0; i < size; i++) {
        result[i] = f(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.ctor !== '[]'; i++) {
        result[i] = ls._0;
        ls = ls._1;
    }

    result.length = i;
    return __Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(idx, arr)
{
    return arr[idx];
});

var _JsArray_unsafeSet = F3(function(idx, val, arr)
{
    var length = arr.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++) {
        result[i] = arr[i];
    }

    result[idx] = val;
    return result;
});

var _JsArray_push = F2(function(val, arr)
{
    var length = arr.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++) {
        result[i] = arr[i];
    }

    result[length] = val;
    return result;
});

var _JsArray_foldl = F3(function(f, acc, arr)
{
    var length = arr.length;

    for (var i = 0; i < length; i++) {
        acc = A2(f, arr[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(f, acc, arr)
{
    for (var i = arr.length - 1; i >= 0; i--) {
        acc = A2(f, arr[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(f, arr)
{
    var length = arr.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++) {
        result[i] = f(arr[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(f, offset, arr)
{
    var length = arr.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++) {
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
    var result = new Array(size);

    for (var i = 0; i < destLen; i++) {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++) {
        result[i + destLen] = source[i];
    }

    return result;
});
