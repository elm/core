/*

import Array exposing (toList)
import Basics exposing (LT, EQ, GT)
import Dict exposing (toList)
import Elm.Kernel.Error exposing (throw)
import Elm.Kernel.List exposing (Cons, Nil)
import Set exposing (toList)

*/


// EQUALITY

function _Utils_eq(x, y)
{
	var stack = [];
	var isEqual = _Utils_eqHelp(x, y, 0, stack);
	var pair;
	while (isEqual && (pair = stack.pop()))
	{
		isEqual = _Utils_eqHelp(pair.x, pair.y, 0, stack);
	}
	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push({ x: x, y: y });
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object')
	{
		if (typeof x === 'function')
		{
			__Error_throw(5);
		}
		return false;
	}

	if (x === null || y === null)
	{
		return false
	}

	// convert Dicts and Sets to lists
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = __Dict_toList(x);
		y = __Dict_toList(y);
	}
	if (x.$ === 'Set_elm_builtin')
	{
		x = __Set_toList(x);
		y = __Set_toList(y);
	}

	// check if lists are equal without recursion
	if (x.$ === '::')
	{
		var a = x;
		var b = y;
		while (a.$ === '::' && b.$ === '::')
		{
			if (!_Utils_eqHelp(a.a, b.a, depth + 1, stack))
			{
				return false;
			}
			a = a.b;
			b = b.b;
		}
		return a.$ === b.$;
	}

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });


// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp__PROD(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	if (!x.$)
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	while (x.$ === '::' && y.$ === '::' && !(ord = _Utils_cmp(x.a, y.a)))
	{
		x = x.b;
		y = y.b;
	}
	return ord || (x.$ === y.$ ? /*EQ*/ 0 : x.$ === '[]' ? /*LT*/ -1 : /*GT*/ 1);
}

function _Utils_cmp__DEBUG(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? /*EQ*/ 0 : a < b ? /*LT*/ -1 : /*GT*/ 1;
	}

	if (x.$[0] === '#')
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	while (x.$ === '::' && y.$ === '::' && !(ord = _Utils_cmp(x.a, y.a)))
	{
		x = x.b;
		y = y.b;
	}
	return ord || (x.$ === y.$ ? /*EQ*/ 0 : x.$ === '[]' ? /*LT*/ -1 : /*GT*/ 1);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) === /*LT*/ -1; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) !== /*GT*/ 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) === /*GT*/ 1; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) !== /*LT*/ -1; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? __Basics_LT : n ? __Basics_GT : __Basics_EQ;
});


// COMMON VALUES

var _Utils_Tuple0__PROD = 0;
var _Utils_Tuple0__DEBUG = { $: '#0' };

function _Utils_Tuple2__PROD(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2__DEBUG(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3__PROD(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3__DEBUG(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr__DEBUG(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (xs.$ === '[]')
	{
		return ys;
	}
	var root = __List_Cons(xs.a, __List_Nil);
	var curr = root;
	xs = xs.b;
	while (xs.$ !== '[]')
	{
		curr.b = __List_Cons(xs.a, __List_Nil);
		xs = xs.b;
		curr = curr.b;
	}
	curr.b = ys;
	return root;
}
