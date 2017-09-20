/*

import Elm.Kernel.Scheduler exposing (binding)

*/


function _Time_neverResolve()
{
	return __Scheduler_binding(function() {});
}

var _Time_now = _Time_neverResolve;
var _Time_sleep = _Time_neverResolve;
var _Time_setInterval = F2(_Time_neverResolve);
