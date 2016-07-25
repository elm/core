// import Maybe

var _elm_lang$core$Native_Array = function() {
/* Helper functions to transform Elm arrays to/from Javascript arrays.
*/

function fromJSArray(arr) {
    var elmArr = _elm_lang$core$Array$empty;

    for (var i = 0; i < arr.length; i++) {
        elmArr = A2(_elm_lang$core$Array$push, arr[i], elmArr);
    }

    return elmArr;
}

function toJSArray(arr) {
    var res = [],
        reducer = F2(function (i, acc) {
            acc.push(i);
            return acc;
        });

    A3(_elm_lang$core$Array$foldl, reducer, res, arr);

    return res;
}

return {
    fromJSArray: fromJSArray,
    toJSArray: toJSArray
};

}();