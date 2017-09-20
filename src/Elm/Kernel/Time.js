/*

import Elm.Kernel.Scheduler exposing (binding, succeed)
import Elm.Kernel.Utils exposing (Tuple0)

*/


function _Time_now()
{
	return __Scheduler_binding(function(callback)
	{
		callback(__Scheduler_succeed(Date.now()));
	});
}

var _Time_setInterval = F2(function(interval, task)
{
	return __Scheduler_binding(function(callback)
	{
		var id = setInterval(function() { _Scheduler_rawSpawn(task); }, interval);
		return function() { clearInterval(id); };
	});
});

function _Time_sleep(time)
{
	return __Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(__Scheduler_succeed(__Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}
