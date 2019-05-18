/*

import Basics exposing (EQ, LT)
import Elm.Kernel.Utils exposing (Tuple2, cmp)
import Maybe exposing (Just, Nothing)

*/


var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return __Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var result = array.slice(0);
    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var sourceLen = source.length;

    var itemsToCopy = n - destLen;
    if (itemsToCopy > sourceLen)
    {
        itemsToCopy = sourceLen;
    }

    var result = new Array(destLen + itemsToCopy);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});

var _JsArray_fromFold = F2(function(fold, container) {
    return A3(fold, foldHelper, [], container);
});

var _JsArray_foldHelper = F2(function(val, arr) {
    return arr.push(val);
});

var _JsArray_sortByFromFold = F3(function(fold, f, container) {
    var arr = A3(fold, foldHelper, [], container);
    arr.sort(function(a, b) {
        return __Utils_cmp(f(a), f(b));
    });
    return arr;
});

var _JsArray_sortWithFromFold = F3(function(fold, f, container) {
    var arr = A3(fold, foldHelper, [], container);
    arr.sort(function(a, b) {
	var ord = A2(f, a, b);
	return ord === __Basics_EQ ? 0 : ord === __Basics_LT ? -1 : 1;
    });
    return arr;
});

var _JsArray_find = F2(function(pred, arr) {
    for (var i = 0, length = arr.length; i < length; i++) {
        var result = pred(arr[i]);
        if (result !== __Maybe_Nothing) {
            return result;
        }
    }

    return __Maybe_Nothing;
});
