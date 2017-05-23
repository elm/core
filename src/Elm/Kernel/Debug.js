/*

import Elm.Kernel.Utils exposing (toString)

*/


var _Debug_log = F2(function(tag, value)
{
	var msg = tag + ': ' + __Utils_toString(value);
	var process = process || {};
	if (process.stdout)
	{
		process.stdout.write(msg);
	}
	else
	{
		console.log(msg);
	}
	return value;
});

function _Debug_crash(message)
{
	throw new Error(message);
}
