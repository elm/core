/*

import Result exposing (Result(Ok,Err))

*/


function _Date_fromIso8601(str)
{
	try
	{
		var i = _Date_if(str, '' , 0, 4, 0, 9999, true);
		i = _Date_if(str, '-', i, 2, 1, 12, false);
		i = _Date_if(str, '-', i, 2, 1, 31, false);

		if (str[i] === 'T')
		{
			i = _Date_if(str, 'T', i, 2, 0, 24, true);
			i = _Date_if(str, ':', i, 2, 0, 59, true);
			var j = _Date_if(str, ':', i, 2, 0, 59, false);
			if (j !== i) { i = _Date_if(str, '.', j, 3, 0, 999, false); }
		}

		var char = str[i];
		i = (char === 'Z') ? i+1 : (char === '+' || char === '-')
			? _Date_if(str, ':', _Date_if(str, char, i, 2, 0, 24, true), 2, 0, 59, true)
			: i;

		var date = new Date(str);
		return (i !== str.length || isNaN(date.getTime()))
			? __Result_Err(_Date_problem(str))
			: __Result_Ok(date);
	}
	catch(e)
	{
		return __Result_Err(_Date_problem(str))
	}
}

function _Date_if(string, char, index, len, min, max, required)
{
	if (char)
	{
		if (string[index] !== char)
		{
			if (required) { throw 0 }
			return index;
		}
		index++;
	}
	var n = string.substr(index, len) - 0;
	if (min <= n && n <= max) { return index + len }
	throw 0;
}

function _Date_problem(str)
{
	return '"' + str + '" is not an ISO 8601 date.'
}

function _Date_year(d)
{
	return d.getFullYear();
}

function _Date_month(d)
{
	return { $: _Date_monthTable[d.getMonth()] };
}

var _Date_monthTable = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

function _Date_day(d)
{
	return d.getDate();
}

function _Date_hour(d)
{
	return d.getHours();
}

function _Date_minute(d)
{
	return d.getMinutes();
}

function _Date_second(d)
{
	return d.getSeconds();
}

function _Date_millisecond(d)
{
	return d.getMilliseconds();
}

function _Date_toTime(d)
{
	return d.getTime();
}

function _Date_fromTime(t)
{
	return new Date(t);
}

function _Date_dayOfWeek(d)
{
	return { $: _Date_dayTable[d.getDay()] };
}

var _Date_dayTable = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
