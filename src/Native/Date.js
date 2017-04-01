
function _Date_fromString(str)
{
	var date = new Date(str);
	return isNaN(date.getTime())
		? _elm_lang$core$Result$Err('Unable to parse \'' + str + '\' as a date. Dates must be in the ISO 8601 format.')
		: _elm_lang$core$Result$Ok(date);
}

function _Date_year(d)
{
	return d.getFullYear();
}

function _Date_month(d)
{
	return { ctor: _Date_monthTable[d.getMonth()] };
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
	return { ctor: _Date_dayTable[d.getDay()] };
}

var _Date_dayTable = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
