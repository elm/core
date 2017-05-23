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

	if (x instanceof Date)
	{
		return x.getTime() === y.getTime();
	}

	if (!('ctor' in x))
	{
		for (var key in x)
		{
			if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
			{
				return false;
			}
		}
		return true;
	}

	// convert Dicts and Sets to lists
	if (x.ctor === 'RBNode_elm_builtin' || x.ctor === 'RBEmpty_elm_builtin')
	{
		x = __Dict_toList(x);
		y = __Dict_toList(y);
	}
	if (x.ctor === 'Set_elm_builtin')
	{
		x = __Set_toList(x);
		y = __Set_toList(y);
	}

	// check if lists are equal without recursion
	if (x.ctor === '::')
	{
		var a = x;
		var b = y;
		while (a.ctor === '::' && b.ctor === '::')
		{
			if (!_Utils_eqHelp(a._0, b._0, depth + 1, stack))
			{
				return false;
			}
			a = a._1;
			b = b._1;
		}
		return a.ctor === b.ctor;
	}

	if (!_Utils_eqHelp(x.ctor, y.ctor, depth + 1, stack))
	{
		return false;
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

	if (x.ctor === '::' || x.ctor === '[]')
	{
		while (x.ctor === '::' && y.ctor === '::')
		{
			var ord = _Utils_cmp(x._0, y._0);
			if (ord !== _Utils_EQ)
			{
				return ord;
			}
			x = x._1;
			y = y._1;
		}
		return x.ctor === y.ctor ? _Utils_EQ : x.ctor === '[]' ? _Utils_LT : _Utils_GT;
	}

	if (x.ctor[0] === '#')
	{
		var ord;
		var n = x.ctor.slice(6) - 0;
		if (n === 0) return _Utils_EQ;
		if (n >= 1) { ord = _Utils_cmp(x._0, y._0); if (ord !== _Utils_EQ) return ord;
		if (n >= 2) { ord = _Utils_cmp(x._1, y._1); if (ord !== _Utils_EQ) return ord;
		if (n >= 3) { ord = _Utils_cmp(x._2, y._2); if (ord !== _Utils_EQ) return ord;
		if (n >= 4) { ord = _Utils_cmp(x._3, y._3); if (ord !== _Utils_EQ) return ord;
		if (n >= 5) { ord = _Utils_cmp(x._4, y._4); if (ord !== _Utils_EQ) return ord;
		if (n >= 6) { ord = _Utils_cmp(x._5, y._5); if (ord !== _Utils_EQ) return ord;
		if (n >= 7) __Error_throw(6); } } } } } }
		return _Utils_EQ;
	}

	__Error_throw(7);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) === _Utils_LT; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) !== _Utils_GT; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) === _Utils_GT; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) !== _Utils_LT; });

var _Utils_ordTable = ['LT', 'EQ', 'GT'];

var _Utils_compare = F2(function(x, y)
{
	return { ctor: _Utils_ordTable[_Utils_cmp(x, y) + 1] };
});


// COMMON VALUES

var _Utils_Tuple0 = {
	ctor: '#0'
};

function _Utils_Tuple2(x, y)
{
	return {
		ctor: '#2',
		_0: x,
		_1: y
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
	if (xs.ctor === '[]')
	{
		return ys;
	}
	var root = __List_Cons(xs._0, __List_Nil);
	var curr = root;
	xs = xs._1;
	while (xs.ctor !== '[]')
	{
		curr._1 = __List_Cons(xs._0, __List_Nil);
		xs = xs._1;
		curr = curr._1;
	}
	curr._1 = ys;
	return root;
});
