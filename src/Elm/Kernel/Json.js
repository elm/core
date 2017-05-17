/*

import Array exposing (initialize)
import Elm.Kernel.List exposing (Cons, Nil)
import Elm.Kernel.Utils exposing (Tuple2)
import Maybe exposing (Maybe(Just,Nothing))
import Result exposing (Result(Ok,Err))

*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		ctor: '_d_succeed',
		msg: msg
	};
}

function _Json_fail(msg)
{
	return {
		ctor: '_d_fail',
		msg: msg
	};
}

function _Json_decodePrimitive(tag)
{
	return {
		ctor: tag
	};
}

var _Json_decodeContainer = F2(function(tag, decoder)
{
	return {
		ctor: tag,
		decoder: decoder
	};
});

function _Json_decodeNull(value)
{
	return {
		ctor: '_d_null',
		value: value
	};
}

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		ctor: '_d_field',
		field: field,
		decoder: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		ctor: '_d_index',
		index: index,
		decoder: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		ctor: '_d_key_value',
		decoder: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		ctor: '_d_map',
		func: f,
		decoders: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		ctor: '_d_andThen',
		decoder: decoder,
		callback: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		ctor: '_d_oneOf',
		decoders: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE HELPERS

function _Json_ok(value)
{
	return { tag: 'ok', value: value };
}

function _Json_badPrimitive(type, value)
{
	return { tag: 'primitive', type: type, value: value };
}

function _Json_badField(field, nestedProblems)
{
	return { tag: 'field', field: field, rest: nestedProblems };
}

function _Json_badOneOf(problems)
{
	return { tag: 'oneOf', problems: problems };
}

function _Json_bad(msg)
{
	return { tag: 'fail', msg: msg };
}

function _Json_badToString(problem)
{
	var context = '_';
	while (problem)
	{
		switch (problem.tag)
		{
			case 'primitive':
				return 'Expecting ' + problem.type
					+ (context === '_' ? '' : ' at ' + context)
					+ ' but instead got: ' + _Json_jsToString(problem.value);

			case 'index':
				context += '[' + problem.index + ']';
				problem = problem.rest;
				break;

			case 'field':
				context += '.' + problem.field;
				problem = problem.rest;
				break;

			case 'oneOf':
				var problems = problem.problems;
				for (var i = 0; i < problems.length; i++)
				{
					problems[i] = _Json_badToString(problems[i]);
				}
				return 'I ran into the following problems'
					+ (context === '_' ? '' : ' at ' + context)
					+ ':\n\n' + problems.join('\n');

			case 'fail':
				return 'I ran into a `fail` decoder'
					+ (context === '_' ? '' : ' at ' + context)
					+ ': ' + problem.msg;
		}
	}
}

function _Json_jsToString(value)
{
	return value === undefined
		? 'undefined'
		: JSON.stringify(value);
}


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	var json;
	try
	{
		json = JSON.parse(string);
	}
	catch (e)
	{
		return __Result_Err('Given an invalid JSON: ' + e.message);
	}
	return run(decoder, json);
});

var _Json_run = F2(function(decoder, value)
{
	var result = _Json_runHelp(decoder, value);
	return (result.tag === 'ok')
		? __Result_Ok(result.value)
		: __Result_Err(_Json_badToString(result));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.ctor)
	{
		case '_d_bool':
			return (typeof value === 'boolean')
				? _Json_ok(value)
				: _Json_badPrimitive('a Bool', value);

		case '_d_int':
			if (typeof value !== 'number') {
				return _Json_badPrimitive('an Int', value);
			}

			if (-2147483647 < value && value < 2147483647 && (value | 0) === value) {
				return _Json_ok(value);
			}

			if (isFinite(value) && !(value % 1)) {
				return _Json_ok(value);
			}

			return _Json_badPrimitive('an Int', value);

		case '_d_float':
			return (typeof value === 'number')
				? _Json_ok(value)
				: _Json_badPrimitive('a Float', value);

		case '_d_string':
			return (typeof value === 'string')
				? _Json_ok(value)
				: (value instanceof String)
					? _Json_ok(value + '')
					: _Json_badPrimitive('a String', value);

		case '_d_null':
			return (value === null)
				? _Json_ok(decoder.value)
				: _Json_badPrimitive('null', value);

		case '_d_value':
			return _Json_ok(value);

		case '_d_list':
			if (!(value instanceof Array))
			{
				return _Json_badPrimitive('a List', value);
			}

			var list = __List_Nil;
			for (var i = value.length; i--; )
			{
				var result = _Json_runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return _Json_badIndex(i, result)
				}
				list = __List_Cons(result.value, list);
			}
			return _Json_ok(list);

		case '_d_array':
			if (!(value instanceof Array))
			{
				return _Json_badPrimitive('an Array', value);
			}

			var len = value.length;
			var array = new Array(len);
			for (var i = len; i--; )
			{
				var result = _Json_runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return _Json_badIndex(i, result);
				}
				array[i] = result.value;
			}
			var elmArray = A2(__Array_initialize, array.length, function (idx) {
				return array[idx];
			});
			return _Json_ok(elmArray);

		case '_d_maybe':
			var result = _Json_runHelp(decoder.decoder, value);
			return (result.tag === 'ok')
				? _Json_ok(__Maybe_Just(result.value))
				: _Json_ok(__Maybe_Nothing);

		case '_d_field':
			var field = decoder.field;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_badPrimitive('an object with a field named `' + field + '`', value);
			}

			var result = _Json_runHelp(decoder.decoder, value[field]);
			return (result.tag === 'ok') ? result : _Json_badField(field, result);

		case '_d_index':
			var index = decoder.index;
			if (!(value instanceof Array))
			{
				return _Json_badPrimitive('an array', value);
			}
			if (index >= value.length)
			{
				return _Json_badPrimitive('a longer array. Need index ' + index + ' but there are only ' + value.length + ' entries', value);
			}

			var result = _Json_runHelp(decoder.decoder, value[index]);
			return (result.tag === 'ok') ? result : _Json_badIndex(index, result);

		case '_d_key_value':
			if (typeof value !== 'object' || value === null || value instanceof Array)
			{
				return _Json_badPrimitive('an object', value);
			}

			var keyValuePairs = __List_Nil;
			for (var key in value)
			{
				var result = _Json_runHelp(decoder.decoder, value[key]);
				if (result.tag !== 'ok')
				{
					return _Json_badField(key, result);
				}
				var pair = __Utils_Tuple2(key, result.value);
				keyValuePairs = __List_Cons(pair, keyValuePairs);
			}
			return _Json_ok(keyValuePairs);

		case '_d_map':
			var answer = decoder.func;
			var decoders = decoder.decoders;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (result.tag !== 'ok')
				{
					return result;
				}
				answer = answer(result.value);
			}
			return _Json_ok(answer);

		case '_d_andThen':
			var result = _Json_runHelp(decoder.decoder, value);
			return (result.tag !== 'ok')
				? result
				: _Json_runHelp(decoder.callback(result.value), value);

		case '_d_oneOf':
			var errors = [];
			var temp = decoder.decoders;
			while (temp.ctor !== '[]')
			{
				var result = _Json_runHelp(temp._0, value);

				if (result.tag === 'ok')
				{
					return result;
				}

				errors.push(result);

				temp = temp._1;
			}
			return _Json_badOneOf(errors);

		case '_d_fail':
			return _Json_bad(decoder.msg);

		case '_d_succeed':
			return _Json_ok(decoder.msg);
	}
}


// EQUALITY

function _Json_equality(a, b)
{
	if (a === b)
	{
		return true;
	}

	if (a.ctor !== b.ctor)
	{
		return false;
	}

	switch (a.ctor)
	{
		case '_d_succeed':
		case '_d_fail':
			return a.msg === b.msg;

		case '_d_bool':
		case '_d_int':
		case '_d_float':
		case '_d_string':
		case '_d_value':
			return true;

		case '_d_null':
			return a.value === b.value;

		case '_d_list':
		case '_d_array':
		case '_d_maybe':
		case '_d_key_value':
			return _Json_equality(a.decoder, b.decoder);

		case '_d_field':
			return a.field === b.field && _Json_equality(a.decoder, b.decoder);

		case '_d_index':
			return a.index === b.index && _Json_equality(a.decoder, b.decoder);

		case '_d_map':
			if (a.func !== b.func)
			{
				return false;
			}
			return _Json_listEquality(a.decoders, b.decoders);

		case '_d_andThen':
			return a.callback === b.callback && _Json_equality(a.decoder, b.decoder);

		case '_d_oneOf':
			return _Json_listEquality(a.decoders, b.decoders);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(value, null, indentLevel);
});

function _Json_identity(value)
{
	return value;
}

function _Json_encodeObject(keyValuePairs)
{
	var obj = {};
	while (keyValuePairs.ctor !== '[]')
	{
		var pair = keyValuePairs._0;
		obj[pair._0] = pair._1;
		keyValuePairs = keyValuePairs._1;
	}
	return obj;
}

var _Json_encodeNull = null;
