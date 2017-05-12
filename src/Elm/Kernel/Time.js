/*

import Elm.Kernel.Scheduler exposing (binding, succeed)

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
