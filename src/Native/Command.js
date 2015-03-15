Elm.Native.Command = {};
Elm.Native.Command.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Command = localRuntime.Native.Command || {};
	if (localRuntime.Native.Command.values)
	{
		return localRuntime.Native.Command.values;
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

	function andThen(command, callback)
	{
		return {
			tag: 'AndThen',
			command: command,
			callback: callback
		};
	}

	function catch_(command, callback)
	{
		return {
			tag: 'Catch',
			command: command,
			callback: callback
		};
	}


	// RUNNER

	function runOne(command) {
		runCommand({ command: command }, function() {});
	}

	function runStream(name, stream, notify)
	{
		var workQueue = [];

		function onComplete()
		{
			var queueResult = workQueue.shift();
			var command = queueResult.command;
			var result = command.tag === 'Succeed'
				? Result.Ok(command.value)
				: Result.Err(command.value);

			setTimeout(function() {
				notify(result);
				if (workQueue.length > 0)
				{
					runCommand(workQueue[0], onComplete);
				}
			}, 0);
		}

		function register(command)
		{
			var root = { command: command };
			workQueue.push(root);
			if (workQueue.length === 1)
			{
				runCommand(root, onComplete);
			}
		}

		Signal.output('loopback-' + name + '-commands', register, stream);
	}

	function mark(status, command)
	{
		return { status: status, command: command };
	}

	function runCommand(root, onComplete)
	{
		var result = mark('runnable', root.command);
		while (result.status === 'runnable')
		{
			result = stepCommand(onComplete, root, result.command);
		}

		if (result.status === 'done')
		{
			root.command = result.command;
			onComplete();
		}

		if (result.status === 'blocked')
		{
			root.command = result.command;
		}
	}

	function stepCommand(onComplete, root, command)
	{
		var tag = command.tag;

		if (tag === 'Succeed' || tag === 'Fail')
		{
			return mark('done', command);
		}

		if (tag === 'Async')
		{
			var placeHolder = {};
			var couldBeSync = true;
			var wasSync = false;

			command.asyncFunction(function(result) {
				placeHolder.tag = result.tag;
				placeHolder.value = result.value;
				if (couldBeSync)
				{
					wasSync = true;
				}
				else
				{
					runCommand(root, onComplete);
				}
			});
			couldBeSync = false;
			return mark(wasSync ? 'done' : 'blocked', placeHolder);
		}

		if (tag === 'AndThen' || tag === 'Catch')
		{
			var result = mark('runnable', command.command);
			while (result.status === 'runnable')
			{
				result = stepCommand(onComplete, root, result.command);
			}

			if (result.status === 'done')
			{
				var activeCommand = result.command;
				var activeTag = activeCommand.tag;

				var succeedChain = activeTag === 'Succeed' && tag === 'AndThen';
				var failChain = activeTag === 'Fail' && tag === 'Catch';

				return (succeedChain || failChain)
					? mark('runnable', command.callback(activeCommand.value))
					: mark('runnable', activeCommand);
			}
			if (result.status === 'blocked')
			{
				return mark('blocked', {
					tag: tag,
					command: result.command,
					callback: command.callback
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

	function spawn(command) {
		return asyncFunction(function(callback) {
			var id = setTimeout(function() {
				runOne(command);
			}, 0);
			callback(succeed(id));
		});
	}


	return localRuntime.Native.Command.values = {
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
