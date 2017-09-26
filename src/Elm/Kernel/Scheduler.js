/*

import Elm.Kernel.Error exposing (throw)
import Elm.Kernel.Utils exposing (Tuple0)

*/


var _Scheduler_MAX_STEPS = 10000;


// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: __1_SUCCEED,
		value: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: __1_FAIL,
		value: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: __1_BINDING,
		callback: callback,
		cancel: null
	};
}

var _Scheduler_flatMap = F2(function(callback, task)
{
	return {
		$: __1_AND_THEN,
		callback: callback,
		task: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: __1_ON_ERROR,
		callback: callback,
		task: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: __1_RECEIVE,
		callback: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var process = {
		$: __2_PROCESS,
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
	return _Scheduler_binding(function(callback) {
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
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(process, msg);
		callback(_Scheduler_succeed(__Utils_Tuple0));
	});
});

function _Scheduler_kill(process)
{
	return _Scheduler_binding(function(callback) {
		var root = process.root;
		if (root.$ === __1_BINDING && root.cancel)
		{
			root.cancel();
		}

		process.root = null;

		callback(_Scheduler_succeed(__Utils_Tuple0));
	});
}

function _Scheduler_sleep(time)
{
	return _Scheduler_binding(function(callback) {
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
		var tag = process.root.$;

		if (tag === __1_SUCCEED)
		{
			while (process.stack && process.stack.$ === __1_ON_ERROR)
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

		if (tag === __1_FAIL)
		{
			while (process.stack && process.stack.$ === __1_AND_THEN)
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

		if (tag === __1_AND_THEN)
		{
			process.stack = {
				$: __1_AND_THEN,
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (tag === __1_ON_ERROR)
		{
			process.stack = {
				$: __1_ON_ERROR,
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (tag === __1_BINDING)
		{
			process.root.cancel = process.root.callback(function(newRoot) {
				process.root = newRoot;
				_Scheduler_enqueue(process);
			});

			break;
		}

		if (tag === __1_RECEIVE)
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

		__Error_throw(10, tag);
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
