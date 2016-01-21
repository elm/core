Elm.Native.Scheduler = {};
Elm.Native.Scheduler.make = function(localRuntime)
{
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Scheduler = localRuntime.Native.Scheduler || {};
	if (localRuntime.Native.Scheduler.values)
	{
		return localRuntime.Native.Scheduler.values;
	}

	var Utils = Elm.Native.Utils.make(localRuntime);


	var MAX_STEPS = 10000;


	// TASKS

	function succeed(value)
	{
		return {
			ctor: '_Task_succeed',
			value: value
		};
	}

	function fail(error)
	{
		return {
			ctor: '_Task_fail',
			value: error
		};
	}

	function nativeBinding(func, cancel)
	{
		return {
			ctor: '_Task_nativeBinding',
			func: func,
			cancel: cancel
		};
	}

	function andThen(task, callback)
	{
		return {
			ctor: '_Task_andThen',
			task: task,
			callback: callback
		};
	}

	function onError(task, callback)
	{
		return {
			ctor: '_Task_onError',
			task: task,
			callback: callback
		};
	}


	// PROCESSES

	function spawn(task)
	{
		var process = {
			ctor: '_Process',
			_0: Utils.guid(),
			root: task,
			stack: null
		}

		enqueue(process);

		return process;
	}

	function kill(process)
	{
		var root = process.root;
		if (root.ctor === '_Task_nativeBinding')
		{
			root.cancel();
		}

		process.root = null;

		return Utils.Tuple0;
	}

	function step(numSteps, process)
	{
		var root = process.root;
		var stack = process.stack;

		while (numSteps < MAX_STEPS)
		{
			var ctor = root.ctor;

			if (ctor === '_Task_succeed')
			{
				while (stack.ctor === '_Task_onError')
				{
					stack = stack.rest;
				}
				if (stack === null)
				{
					break;
				}
				root = stack.callback(root.value);
				stack = stack.rest;
				++numSteps;
				continue;
			}

			if (ctor === '_Task_fail')
			{
				while (stack.ctor === '_Task_andThen')
				{
					stack = stack.rest;
				}
				if (stack === null)
				{
					break;
				}
				root = stack.callback(root.value);
				stack = stack.rest;
				++numSteps;
				continue;
			}

			if (ctor === '_Task_andThen')
			{
				stack = {
					ctor: '_Task_andThen',
					callback: root.callback,
					rest: stack
				};
				root = root.task;
				++numSteps;
				continue;
			}

			if (ctor === '_Task_onError')
			{
				stack = {
					ctor: '_Task_onError',
					callback: root.callback,
					rest: stack
				};
				root = root.task;
				++numSteps;
				continue;
			}

			if (ctor === '_Task_nativeBinding')
			{
				root.func(function(newRoot) {
					process.root = newRoot;
					enqueue(process);
				});

				break;
			}
		}

		if (numSteps < MAX_STEPS)
		{
			return numSteps + 1;
		}

		process.root = root;
		process.stack = stack;
		enqueue(process);

		return numSteps;
	}


	// WORK QUEUE

	var workQueue = [];

	function enqueue(process)
	{
		workQueue.push(process);
	}

	function work()
	{
		var numSteps = 0;
		var process;
		while (numSteps < MAX_STEPS && (process = workQueue.shift()))
		{
			numSteps = step(numSteps, process);
		}
		if (!process)
		{
			return;
		}
		setTimeout(work, 0);
	}


	return localRuntime.Native.Scheduler.values = {
		succeed: succeed,
		fail: fail,
		nativeBinding: nativeBinding,
		andThen: F2(andThen),
		onError: F2(onError),

		spawn: spawn,
		kill: kill,

		work: work
	};
};
