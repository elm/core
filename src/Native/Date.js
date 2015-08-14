Elm.Native.Date = {};
Elm.Native.Date.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Date = localRuntime.Native.Date || {};
	if (localRuntime.Native.Date.values)
	{
		return localRuntime.Native.Date.values;
	}

	var Result = Elm.Result.make(localRuntime);

	function readDate(str)
	{
		var date = new Date(str);
		return isNaN(date.getTime())
			? Result.Err('unable to parse \'' + str + '\' as a date')
			: Result.Ok(date);
	}

	var dayTable = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
	var monthTable =
		['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
		 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];


	return localRuntime.Native.Date.values = {
		read: readDate,
		year: function(d) { return d.getFullYear(); },
		month: function(d) { return { ctor: monthTable[d.getMonth()] }; },
		day: function(d) { return d.getDate(); },
		hour: function(d) { return d.getHours(); },
		minute: function(d) { return d.getMinutes(); },
		second: function(d) { return d.getSeconds(); },
		millisecond: function(d) { return d.getMilliseconds(); },
		toTime: function(d) { return d.getTime(); },
		fromTime: function(t) { return new Date(t); },
		dayOfWeek: function(d) { return { ctor: dayTable[d.getDay()] }; }
	};
};
