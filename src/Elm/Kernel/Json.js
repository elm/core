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
		$: __1_SUCCEED,
		msg: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: __1_FAIL,
		msg: msg
	};
}

var _Json_decodeInt = { $: __1_INT };
var _Json_decodeBool = { $: __1_BOOL };
var _Json_decodeFloat = { $: __1_FLOAT };
var _Json_decodeValue = { $: __1_VALUE };
var _Json_decodeString = { $: __1_STRING };

function _Json_decodeList(decoder) { return { $: __1_LIST, decoder: decoder }; }
function _Json_decodeArray(decoder) { return { $: __1_ARRAY, decoder: decoder }; }
function _Json_decodeMaybe(decoder) { return { $: __1_MAYBE, decoder: decoder }; }

function _Json_decodeNull(value) { return { $: __1_NULL, value: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: __1_FIELD,
		field: field,
		decoder: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: __1_INDEX,
		index: index,
		decoder: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: __1_KEY_VALUE,
		decoder: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: __1_MAP,
		func: f,
		decoders: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: __1_AND_THEN,
		decoder: decoder,
		callback: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: __1_ONE_OF,
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
	return { tag: __2_OK, value: value };
}

function _Json_badPrimitive(type, value)
{
	return { tag: __2_PRIMITIVE, type: type, value: value };
}

function _Json_badField(field, nestedProblems)
{
	return { tag: __2_FIELD, field: field, rest: nestedProblems };
}

function _Json_badIndex(index, nestedProblems)
{
	return { tag: __2_INDEX, index: index, rest: nestedProblems };
}

function _Json_badOneOf(problems)
{
	return { tag: __2_ONE_OF, problems: problems };
}

function _Json_bad(msg)
{
	return { tag: __2_FAIL, msg: msg };
}

function _Json_badToString(problem)
{
	var context = '_';
	while (problem)
	{
		switch (problem.tag)
		{
			case __2_PRIMITIVE:
				return 'Expecting ' + problem.type
					+ (context === '_' ? '' : ' at ' + context)
					+ ' but instead got: ' + _Json_jsToString(problem.value);

			case __2_INDEX:
				context += '[' + problem.index + ']';
				problem = problem.rest;
				break;

			case __2_FIELD:
				context += '.' + problem.field;
				problem = problem.rest;
				break;

			case __2_ONE_OF:
				var problems = problem.problems;
				for (var i = 0; i < problems.length; i++)
				{
					problems[i] = _Json_badToString(problems[i]);
				}
				return 'I ran into the following problems'
					+ (context === '_' ? '' : ' at ' + context)
					+ ':\n\n' + problems.join('\n');

			case __2_FAIL:
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
	return (result.tag === __2_OK)
		? __Result_Ok(result.value)
		: __Result_Err(_Json_badToString(result));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case __1_BOOL:
			return (typeof value === 'boolean')
				? _Json_ok(value)
				: _Json_badPrimitive('a Bool', value);

		case __1_INT:
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

		case __1_FLOAT:
			return (typeof value === 'number')
				? _Json_ok(value)
				: _Json_badPrimitive('a Float', value);

		case __1_STRING:
			return (typeof value === 'string')
				? _Json_ok(value)
				: (value instanceof String)
					? _Json_ok(value + '')
					: _Json_badPrimitive('a String', value);

		case __1_NULL:
			return (value === null)
				? _Json_ok(decoder.value)
				: _Json_badPrimitive('null', value);

		case __1_VALUE:
			return _Json_ok(value);

		case __1_LIST:
			if (!(value instanceof Array))
			{
				return _Json_badPrimitive('a List', value);
			}

			var list = __List_Nil;
			for (var i = value.length; i--; )
			{
				var result = _Json_runHelp(decoder.decoder, value[i]);
				if (result.tag !== __2_OK)
				{
					return _Json_badIndex(i, result)
				}
				list = __List_Cons(result.value, list);
			}
			return _Json_ok(list);

		case __1_ARRAY:
			if (!(value instanceof Array))
			{
				return _Json_badPrimitive('an Array', value);
			}

			var len = value.length;
			var array = new Array(len);
			for (var i = len; i--; )
			{
				var result = _Json_runHelp(decoder.decoder, value[i]);
				if (result.tag !== __2_OK)
				{
					return _Json_badIndex(i, result);
				}
				array[i] = result.value;
			}
			var elmArray = A2(__Array_initialize, array.length, function (idx) {
				return array[idx];
			});
			return _Json_ok(elmArray);

		case __1_MAYBE:
			var result = _Json_runHelp(decoder.decoder, value);
			return (result.tag === __2_OK)
				? _Json_ok(__Maybe_Just(result.value))
				: _Json_ok(__Maybe_Nothing);

		case __1_FIELD:
			var field = decoder.field;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_badPrimitive('an object with a field named `' + field + '`', value);
			}

			var result = _Json_runHelp(decoder.decoder, value[field]);
			return (result.tag === __2_OK) ? result : _Json_badField(field, result);

		case __1_INDEX:
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
			return (result.tag === __2_OK) ? result : _Json_badIndex(index, result);

		case __1_KEY_VALUE:
			if (typeof value !== 'object' || value === null || value instanceof Array)
			{
				return _Json_badPrimitive('an object', value);
			}

			var keyValuePairs = __List_Nil;
			for (var key in value)
			{
				var result = _Json_runHelp(decoder.decoder, value[key]);
				if (result.tag !== __2_OK)
				{
					return _Json_badField(key, result);
				}
				var pair = __Utils_Tuple2(key, result.value);
				keyValuePairs = __List_Cons(pair, keyValuePairs);
			}
			return _Json_ok(keyValuePairs);

		case __1_MAP:
			var answer = decoder.func;
			var decoders = decoder.decoders;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (result.tag !== __2_OK)
				{
					return result;
				}
				answer = answer(result.value);
			}
			return _Json_ok(answer);

		case __1_AND_THEN:
			var result = _Json_runHelp(decoder.decoder, value);
			return (result.tag !== __2_OK)
				? result
				: _Json_runHelp(decoder.callback(result.value), value);

		case __1_ONE_OF:
			var errors = [];
			var temp = decoder.decoders;
			while (temp.$ !== '[]')
			{
				var result = _Json_runHelp(temp.a, value);

				if (result.tag === __2_OK)
				{
					return result;
				}

				errors.push(result);

				temp = temp.b;
			}
			return _Json_badOneOf(errors);

		case __1_FAIL:
			return _Json_bad(decoder.msg);

		case __1_SUCCEED:
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

	if (a.$ !== b.$)
	{
		return false;
	}

	switch (a.$)
	{
		case __1_SUCCEED:
		case __1_FAIL:
			return a.msg === b.msg;

		case __1_BOOL:
		case __1_INT:
		case __1_FLOAT:
		case __1_STRING:
		case __1_VALUE:
			return true;

		case __1_NULL:
			return a.value === b.value;

		case __1_LIST:
		case __1_ARRAY:
		case __1_MAYBE:
		case __1_KEY_VALUE:
			return _Json_equality(a.decoder, b.decoder);

		case __1_FIELD:
			return a.field === b.field && _Json_equality(a.decoder, b.decoder);

		case __1_INDEX:
			return a.index === b.index && _Json_equality(a.decoder, b.decoder);

		case __1_MAP:
			if (a.func !== b.func)
			{
				return false;
			}
			return _Json_listEquality(a.decoders, b.decoders);

		case __1_AND_THEN:
			return a.callback === b.callback && _Json_equality(a.decoder, b.decoder);

		case __1_ONE_OF:
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
	while (keyValuePairs.$ !== '[]')
	{
		var pair = keyValuePairs.a;
		obj[pair.a] = pair.b;
		keyValuePairs = keyValuePairs.b;
	}
	return obj;
}

var _Json_encodeNull = null;
