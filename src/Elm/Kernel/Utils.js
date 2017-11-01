/*

import Array exposing (toList)
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

var _Utils_LT = -1, _Utils_EQ = 0, _Utils_GT = 1;

function _Utils_cmp(x, y)
{
	if (typeof x !== 'object')
	{
		return x === y ? _Utils_EQ : x < y ? _Utils_LT : _Utils_GT;
	}

	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? _Utils_EQ : a < b ? _Utils_LT : _Utils_GT;
	}

	if (x.$ === '::' || x.$ === '[]')
	{
		while (x.$ === '::' && y.$ === '::')
		{
			var ord = _Utils_cmp(x.a, y.a);
			if (ord !== _Utils_EQ)
			{
				return ord;
			}
			x = x.b;
			y = y.b;
		}
		return x.$ === y.$ ? _Utils_EQ : x.$ === '[]' ? _Utils_LT : _Utils_GT;
	}

	if (x.$[0] === '#')
	{
		var ord;
		return x.$ === '#0'
			? _Utils_EQ
			:
		((ord = _Utils_cmp(x.a, y.a)) !== _Utils_EQ)
			? ord
			:
		((ord = _Utils_cmp(x.b, y.b)) !== _Utils_EQ || x.$ === '#2')
			? ord
			:
		_Utils_cmp(x.c, y.c);
	}

	__Error_throw(7);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) === _Utils_LT; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) !== _Utils_GT; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) === _Utils_GT; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) !== _Utils_LT; });

var _Utils_ordTable = [{ $: 'LT' }, { $: 'EQ' }, { $: 'GT' }];

var _Utils_compare = F2(function(x, y)
{
	return _Utils_ordTable[_Utils_cmp(x, y) + 1];
});


// COMMON VALUES

var _Utils_Tuple0 = {
	$: '#0'
};

function _Utils_Tuple2(x, y)
{
	return {
		$: '#2',
		a: x,
		b: y
	};
}

function _Utils_chr(c)
{
	return new String(c);
}


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

var _Utils_append = F2(function(xs, ys)
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
});
