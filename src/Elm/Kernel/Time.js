// import Elm.Kernel.Scheduler

function _Time_now()
{
	return _Scheduler_nativeBinding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}

var _Time_setInterval = F2(function(interval, task)
{
	return _Scheduler_nativeBinding(function(callback)
	{
		var id = setInterval(function() { _Scheduler_rawSpawn(task); }, interval);
		return function() { clearInterval(id); };
	});
});
