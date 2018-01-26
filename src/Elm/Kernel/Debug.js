/*

import Array exposing (toList)
import Dict exposing (toList)
import Elm.Kernel.Error exposing (throw)
import Set exposing (toList)

*/


// LOG

var _Debug_log__PROD = F2(function(tag, value)
{
	return value;
});

var _Debug_log__DEBUG = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// CRASHES

function _Debug_crash(moduleName, region)
{
	return function(message) {
		__Error_throw(8, moduleName, region, message);
	};
}

function _Debug_crashCase(moduleName, region, value)
{
	return function(message) {
		__Error_throw(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString__PROD(v)
{
	return '<internals>';
}

function _Debug_toString__DEBUG(v)
{
	var type = typeof v;
	if (type === 'function')
	{
		return '<function>';
	}

	if (type === 'boolean')
	{
		return v ? 'True' : 'False';
	}

	if (type === 'number')
	{
		return v + '';
	}

	if (v instanceof String)
	{
		return "'" + _Debug_addSlashes(v, true) + "'";
	}

	if (type === 'string')
	{
		return '"' + _Debug_addSlashes(v, false) + '"';
	}

	if (type === 'object' && '$' in v)
	{
		var tag = v.$;

		if (typeof tag === 'number')
		{
			return '<internals>';
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in v)
			{
				if (k === '$') continue;
				output.push(_Debug_toString(v[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return 'Set.fromList ' + _Debug_toString(__Set_toList(v));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return 'Dict.fromList ' + _Debug_toString(__Dict_toList(v));
		}

		if (tag === 'Array_elm_builtin')
		{
			return 'Array.fromList ' + _Debug_toString(__Array_toList(v));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			v.b && (output += _Debug_toString(v.a))

			for (; v = v.b;) // WHILE_CONS
			{
				output += ',' + _Debug_toString(v.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in v)
		{
			if (i === '$') continue;
			var str = _Debug_toString(v[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return tag + output;
	}

	if (type === 'object')
	{
		var output = [];
		for (var k in v)
		{
			output.push(k + ' = ' + _Debug_toString(v[k]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return '<internals>';
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}
