/*

import Array exposing (initialize)
import Elm.Kernel.List exposing (Cons, Nil, fromArray)
import Elm.Kernel.Utils exposing (Tuple2)
import List exposing (reverse)
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


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return __Result_Err({ $: 'Failure', a: 'This is not valid JSON! ' + e.message, b: string });
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case __1_BOOL:
			return (typeof value === 'boolean')
				? __Result_Ok(value)
				: _Json_expecting('a BOOL', value);

		case __1_INT:
			if (typeof value !== 'number') {
				return _Json_expecting('an INT', value);
			}

			if (-2147483647 < value && value < 2147483647 && (value | 0) === value) {
				return __Result_Ok(value);
			}

			if (isFinite(value) && !(value % 1)) {
				return __Result_Ok(value);
			}

			return _Json_expecting('an INT', value);

		case __1_FLOAT:
			return (typeof value === 'number')
				? __Result_Ok(value)
				: _Json_expecting('a FLOAT', value);

		case __1_STRING:
			return (typeof value === 'string')
				? __Result_Ok(value)
				: (value instanceof String)
					? __Result_Ok(value + '')
					: _Json_expecting('a STRING', value);

		case __1_NULL:
			return (value === null)
				? __Result_Ok(decoder.value)
				: _Json_expecting('null', value);

		case __1_VALUE:
			return __Result_Ok(_Json_wrap(value));

		case __1_LIST:
			if (!Array.isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.decoder, value, __List_fromArray);

		case __1_ARRAY:
			if (!Array.isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.decoder, value, _Json_toElmArray);

		case __1_FIELD:
			var field = decoder.field;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.decoder, value[field]);
			return (result.$ === 'Ok') ? result : __Result_Err({ $: 'Field', a: field, b: result.a });

		case __1_INDEX:
			var index = decoder.index;
			if (!Array.isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.decoder, value[index]);
			return (result.$ === 'Ok') ? result : __Result_Err({ $: 'Index', a: index, b: result.a });

		case __1_KEY_VALUE:
			if (typeof value !== 'object' || value === null || Array.isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = __List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.decoder, value[key]);
					if (result.$ !== 'Ok')
					{
						return __Result_Err({ $: 'Field', a: key, b: result.a });
					}
					var pair = __Utils_Tuple2(key, result.value);
					keyValuePairs = __List_Cons(pair, keyValuePairs);
				}
			}
			return __Result_Ok(__List_reverse(keyValuePairs));

		case __1_MAP:
			var answer = decoder.func;
			var decoders = decoder.decoders;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (result.$ !== 'Ok')
				{
					return result;
				}
				answer = answer(result.a);
			}
			return __Result_Ok(answer);

		case __1_AND_THEN:
			var result = _Json_runHelp(decoder.decoder, value);
			return (result.$ !== 'Ok')
				? result
				: _Json_runHelp(decoder.callback(result.a), value);

		case __1_ONE_OF:
			var errors = __List_Nil;
			var temp = decoder.decoders;
			while (temp.$ !== '[]')
			{
				var result = _Json_runHelp(temp.a, value);
				if (result.$ === 'Ok')
				{
					return result;
				}
				errors = __List_Cons(result.a, errors);
				temp = temp.b;
			}
			return __Result_Err({ $: 'OneOf', a: __List_reverse(errors) });

		case __1_FAIL:
			return __Result_Err({ $: 'Failure', a: decoder.msg, b: value });

		case __1_SUCCEED:
			return __Result_Ok(decoder.msg);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (result.$ !== 'Ok')
		{
			return __Result_Err({ $: 'Index', a: i, b: result.a });
		}
		array[i] = result.a;
	}
	return __Result_Ok(toElmValue(array));
}

function _Json_toElmArray(array)
{
	return A2(__Array_initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return __Result_Err({ $: 'Failure', a: 'Expecting ' + type, b: value });
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case __1_SUCCEED:
		case __1_FAIL:
			return x.msg === y.msg;

		case __1_BOOL:
		case __1_INT:
		case __1_FLOAT:
		case __1_STRING:
		case __1_VALUE:
			return true;

		case __1_NULL:
			return x.value === y.value;

		case __1_LIST:
		case __1_ARRAY:
		case __1_KEY_VALUE:
			return _Json_equality(x.decoder, y.decoder);

		case __1_FIELD:
			return x.field === y.field && _Json_equality(x.decoder, y.decoder);

		case __1_INDEX:
			return x.index === y.index && _Json_equality(x.decoder, y.decoder);

		case __1_MAP:
			return x.func === y.func && _Json_arrayEquality(x.decoders, y.decoders);

		case __1_AND_THEN:
			return x.callback === y.callback && _Json_equality(x.decoder, y.decoder);

		case __1_ONE_OF:
			return _Json_listEquality(x.decoders, y.decoders);
	}
}

function _Json_arrayEquality(aDecoders, bDecoders)
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

function _Json_listEquality(aDecoders, bDecoders)
{
	var tempA = aDecoders;
	var tempB = bDecoders;
	while (tempA.$ !== '[]')
	{
		if (tempB.$ === '[]')
		{
			return false;
		}
		if (!_Json_equality(tempA.a, tempB.a))
		{
			return false;
		}
		tempA = tempA.b;
		tempB = tempB.b;
	}
	if (tempB.$ !== '[]')
	{
		return false;
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel);
});

function _Json_wrap__DEV(value) { return { $: __0_JSON, a: value }; }
function _Json_unwrap__DEV(value) { return value.a; }

function _Json_wrap__PROD(value) { return value; }
function _Json_unwrap__PROD(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(entry));
		return array;
	});
}

var _Json_encodeNull = null;
