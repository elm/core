// import Elm.Kernel.Utils exposing (Tuple0)


var _Scheduler_MAX_STEPS = 10000;


// TASKS

function _Scheduler_succeed(value)
{
	return {
		ctor: '_Task_succeed',
		value: value
	};
}

function _Scheduler_fail(error)
{
	return {
		ctor: '_Task_fail',
		value: error
	};
}

function _Scheduler_nativeBinding(callback)
{
	return {
		ctor: '_Task_nativeBinding',
		callback: callback,
		cancel: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		ctor: '_Task_andThen',
		callback: callback,
		task: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		ctor: '_Task_onError',
		callback: callback,
		task: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		ctor: '_Task_receive',
		callback: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var process = {
		ctor: '_Process',
		id: _Scheduler_guid++,
		root: task,
		stack: null,
		mailbox: []
	};

	_Scheduler_enqueue(process);

	return process;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_nativeBinding(function(callback) {
		var process = _Scheduler_rawSpawn(task);
		callback(_Scheduler_succeed(process));
	});
}

function _Scheduler_rawSend(process, msg)
{
	process.mailbox.push(msg);
	_Scheduler_enqueue(process);
}

var _Scheduler_send = F2(function(process, msg)
{
	return _Scheduler_nativeBinding(function(callback) {
		_Scheduler_rawSend(process, msg);
		callback(_Scheduler_succeed(__Utils_Tuple0));
	});
});

function _Scheduler_kill(process)
{
	return _Scheduler_nativeBinding(function(callback) {
		var root = process.root;
		if (root.ctor === '_Task_nativeBinding' && root.cancel)
		{
			root.cancel();
		}

		process.root = null;

		callback(_Scheduler_succeed(__Utils_Tuple0));
	});
}

function _Scheduler_sleep(time)
{
	return _Scheduler_nativeBinding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(__Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}


// STEP PROCESSES

function _Scheduler_step(numSteps, process)
{
	while (numSteps < _Scheduler_MAX_STEPS)
	{
		var ctor = process.root.ctor;

		if (ctor === '_Task_succeed')
		{
			while (process.stack && process.stack.ctor === '_Task_onError')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_fail')
		{
			while (process.stack && process.stack.ctor === '_Task_andThen')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_andThen')
		{
			process.stack = {
				ctor: '_Task_andThen',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_onError')
		{
			process.stack = {
				ctor: '_Task_onError',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_nativeBinding')
		{
			process.root.cancel = process.root.callback(function(newRoot) {
				process.root = newRoot;
				_Scheduler_enqueue(process);
			});

			break;
		}

		if (ctor === '_Task_receive')
		{
			var mailbox = process.mailbox;
			if (mailbox.length === 0)
			{
				break;
			}

			process.root = process.root.callback(mailbox.shift());
			++numSteps;
			continue;
		}

		throw new Error(ctor);
	}

	if (numSteps < _Scheduler_MAX_STEPS)
	{
		return numSteps + 1;
	}
	_Scheduler_enqueue(process);

	return numSteps;
}


// WORK QUEUE

var _Scheduler_working = false;
var _Scheduler_workQueue = [];

function _Scheduler_enqueue(process)
{
	_Scheduler_workQueue.push(process);

	if (!_Scheduler_working)
	{
		setTimeout(_Scheduler_work, 0);
		_Scheduler_working = true;
	}
}

function _Scheduler_work()
{
	var numSteps = 0;
	var process;
	while (numSteps < _Scheduler_MAX_STEPS && (process = _Scheduler_workQueue.shift()))
	{
		if (process.root)
		{
			numSteps = _Scheduler_step(numSteps, process);
		}
	}
	if (!process)
	{
		_Scheduler_working = false;
		return;
	}
	setTimeout(_Scheduler_work, 0);
}
