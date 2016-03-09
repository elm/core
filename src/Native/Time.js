//import Native.Scheduler //

var _elm_lang$core$Native_Time = function() {

var now = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
	callback(_elm_lang$core$Native_Scheduler.succeed(Date.now()));
});

return {
	now: now,
};

}();