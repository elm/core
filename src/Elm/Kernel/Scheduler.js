/*

import Elm.Kernel.Utils exposing (Tuple0)

*/


// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: __1_SUCCEED,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: __1_FAIL,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: __1_BINDING,
		a: callback,
		b: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: __1_AND_THEN,
		a: callback,
		b: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: __1_ON_ERROR,
		a: callback,
		b: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: __1_RECEIVE,
		a: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: __2_PROCESS,
		id: _Scheduler_guid++,
		root: task,
		stack: null,
		mb: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		var proc = _Scheduler_rawSpawn(task);
		callback(_Scheduler_succeed(proc));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.mb.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(__Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.root;
		if (task.$ === __1_BINDING && task.b)
		{
			task.b();
		}

		proc.root = null;

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


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mb : [msg]
  }

*/
function _Scheduler_enqueue(proc)
{
	while (proc.root)
	{
		var rootTag = proc.root.$;
		if (rootTag === __1_SUCCEED || rootTag === __1_FAIL)
		{
			while (proc.stack && proc.stack.$ !== rootTag)
			{
				proc.stack = proc.stack.b;
			}
			if (!proc.stack)
			{
				return;
			}
			proc.root = proc.stack.a(proc.root.a);
			proc.stack = proc.stack.rest;
		}
		else if (rootTag === __1_BINDING)
		{
			proc.root.b = proc.root.a(function(newRoot) {
				proc.root = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === __1_RECEIVE)
		{
			if (proc.mb.length === 0)
			{
				return;
			}
			proc.root = proc.root.a(proc.mb.shift());
		}
		else // if (rootTag === __1_AND_THEN || rootTag === __1_ON_ERROR)
		{
			proc.stack = {
				$: rootTag === __1_AND_THEN ? __1_SUCCEED : __1_FAIL,
				a: proc.root.a,
				b: proc.stack
			};
			proc.root = proc.root.b;
		}
	}
}
