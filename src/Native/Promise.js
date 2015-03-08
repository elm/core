Elm.Native.Promise = {};
Elm.Native.Promise.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Promise = localRuntime.Native.Promise || {};
	if (localRuntime.Native.Promise.values)
	{
		return localRuntime.Native.Promise.values;
	}

	var Result = Elm.Result.make(localRuntime);
	var Signal = Elm.Native.Signal.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);


	// CONSTRUCTORS

	function succeed(value)
	{
		return {
			tag: 'Succeed',
			value: value
		};
	}

	function fail(error)
	{
		return {
			tag: 'Fail',
			value: error
		};
	}

	function asyncFunction(func)
	{
		return {
			tag: 'Async',
			asyncFunction: func
		};
	}

	function andThen(promise, callback)
	{
		return {
			tag: 'AndThen',
			promise: promise,
			callback: callback
		};
	}

	function catch_(promise, callback)
	{
		return {
			tag: 'Catch',
			promise: promise,
			callback: callback
		};
	}


	// RUNNER

	function runOne(promise) {
		runPromise({ promise: promise }, function() {});
	}

	function runStream(name, stream, notify)
	{
		var workQueue = [];

		function onComplete()
		{
			var result = workQueue.shift();
			setTimeout(function() {
				notify(result);
				if (workQueue.length > 0)
				{
					runPromise(workQueue[0], onComplete);
				}
			}, 0);
		}

		function register(promise)
		{
			var root = { promise: promise };
			workQueue.push(root);
			if (workQueue.length === 1)
			{
				runPromise(root, onComplete);
			}
		}

		Signal.output('loopback-' + name + '-promises', register, stream);
	}

	function mark(status, promise)
	{
		return { status: status, promise: promise };
	}

	function runPromise(root, onComplete)
	{
		var result = mark('runnable', root.promise);
		while (result.status === 'runnable')
		{
			result = stepPromise(onComplete, root, result.promise);
		}

		if (result.status === 'done')
		{
			onComplete();
		}

		if (result.status === 'blocked')
		{
			root.promise = result.promise;
		}
	}

	function stepPromise(onComplete, root, promise)
	{
		var tag = promise.tag;

		if (tag === 'Succeed' || tag === 'Fail')
		{
			return mark('done', promise);
		}

		if (tag === 'Async')
		{
			var placeHolder = {};
			var couldBeSync = true;
			var wasSync = false;

			promise.asyncFunction(function(result) {
				placeHolder.tag = result.tag;
				placeHolder.value = result.value;
				if (couldBeSync)
				{
					wasSync = true;
				}
				else
				{
					runPromise(root, onComplete);
				}
			});
			couldBeSync = false;
			return mark(wasSync ? 'done' : 'blocked', placeHolder);
		}

		if (tag === 'AndThen' || tag === 'Catch')
		{
			var result = mark('runnable', promise.promise);
			while (result.status === 'runnable')
			{
				result = stepPromise(onComplete, root, result.promise);
			}

			if (result.status === 'done')
			{
				var activePromise = result.promise;
				var activeTag = activePromise.tag;

				var succeedChain = activeTag === 'Succeed' && tag === 'AndThen';
				var failChain = activeTag === 'Fail' && tag === 'Catch';

				return (succeedChain || failChain)
					? mark('runnable', promise.callback(activePromise.value))
					: mark('runnable', activePromise);
			}
			if (result.status === 'blocked')
			{
				return mark('blocked', {
					tag: tag,
					promise: result.promise,
					callback: promise.callback
				});
			}
		}
	}


	// THREADS

	function sleep(time) {
		return asyncFunction(function(callback) {
			setTimeout(function() {
				callback(succeed(Utils.Tuple0));
			}, time);
		});
	}

	function spawn(promise) {
		return asyncFunction(function(callback) {
			var id = setTimeout(function() {
				runOne(promise);
			}, 0);
			callback(succeed(id));
		});
	}


	return localRuntime.Native.Promise.values = {
		succeed: succeed,
		fail: fail,
		asyncFunction: asyncFunction,
		andThen: F2(andThen),
		catch_: F2(catch_),
		runStream: runStream,
		runOne: runOne,
		spawn: spawn,
		sleep: sleep
	};
};
