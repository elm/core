/*

import Elm.Kernel.Error exposing (throw)
import Elm.Kernel.Json exposing (run)
import Elm.Kernel.List exposing (Cons, Nil)
import Elm.Kernel.Scheduler exposing (flatMap, binding, rawSend, rawSpawn, receive, send, succeed)
import Elm.Kernel.Utils exposing (Tuple0)

*/


// PROGRAMS

function _Platform_program(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flags !== 'undefined')
				{
					__Error_throw(0, moduleName);
				}

				return _Platform_initialize(
					impl.init,
					impl.update,
					impl.subscriptions,
					_Platform_renderer
				);
			};
		};
	};
}

function _Platform_programWithFlags(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flagDecoder === 'undefined')
				{
					__Error_throw(1, moduleName);
				}

				var result = A2(__Json_run, flagDecoder, flags);
				if (result.$ === 'Err')
				{
					__Error_throw(2, moduleName, result.a);
				}

				return _Platform_initialize(
					impl.init(result.a),
					impl.update,
					impl.subscriptions,
					_Platform_renderer
				);
			};
		};
	};
}

function _Platform_renderer()
{
	return function() {};
}


// INITIALIZE A PROGRAM

function _Platform_initialize(init, update, subscriptions, renderer)
{
	// ambient state
	var managers = {};
	var updateView;

	// init and update state in main process
	var initApp = __Scheduler_binding(function(callback) {
		var model = init.a;
		updateView = renderer(enqueue, model);
		var cmds = init.b;
		var subs = subscriptions(model);
		_Platform_dispatchEffects(managers, cmds, subs);
		callback(__Scheduler_succeed(model));
	});

	function onMessage(msg, model)
	{
		return __Scheduler_binding(function(callback) {
			var results = A2(update, msg, model);
			model = results.a;
			updateView(model);
			var cmds = results.b;
			var subs = subscriptions(model);
			_Platform_dispatchEffects(managers, cmds, subs);
			callback(__Scheduler_succeed(model));
		});
	}

	var mainProcess = _Platform_spawnLoop(initApp, onMessage);

	function enqueue(msg)
	{
		__Scheduler_rawSend(mainProcess, msg);
	}

	var ports = _Platform_setupEffects(managers, enqueue);

	return ports ? { ports: ports } : {};
}


// EFFECT MANAGERS

var _Platform_effectManagers = {};

function _Platform_setupEffects(managers, callback)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.isForeign)
		{
			ports = ports || {};
			ports[key] = manager.tag === 'cmd'
				? _Platform_setupOutgoingPort(key)
				: _Platform_setupIncomingPort(key, callback);
		}

		managers[key] = _Platform_makeManager(manager, callback);
	}

	return ports;
}

function _Platform_makeManager(info, callback)
{
	var router = {
		main: callback,
		self: undefined
	};

	var tag = info.tag;
	var onEffects = info.onEffects;
	var onSelfMsg = info.onSelfMsg;

	function onMessage(msg, state)
	{
		if (msg.$ === __2_SELF)
		{
			return A3(onSelfMsg, router, msg.a, state);
		}

		var fx = msg.a;
		switch (tag)
		{
			case 'cmd':
				return A3(onEffects, router, fx.cmds, state);

			case 'sub':
				return A3(onEffects, router, fx.subs, state);

			case 'fx':
				return A4(onEffects, router, fx.cmds, fx.subs, state);
		}
	}

	var process = _Platform_spawnLoop(info.init, onMessage);
	router.self = process;
	return process;
}

var _Platform_sendToApp = F2(function(router, msg)
{
	return __Scheduler_binding(function(callback)
	{
		router.main(msg);
		callback(__Scheduler_succeed(__Utils_Tuple0));
	});
});

var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(__Scheduler_send, router.self, {
		$: __2_SELF,
		a: msg
	});
});


// HELPER for STATEFUL LOOPS

function _Platform_spawnLoop(init, onMessage)
{
	function loop(state)
	{
		var handleMsg = __Scheduler_receive(function(msg) {
			return onMessage(msg, state);
		});
		return A2(__Scheduler_flatMap, loop, handleMsg);
	}

	var task = A2(__Scheduler_flatMap, loop, init);

	return __Scheduler_rawSpawn(task);
}


// BAGS

function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: __2_LEAF,
			home: home,
			value: value
		};
	};
}

function _Platform_batch(list)
{
	return {
		$: __2_NODE,
		branches: list
	};
}

var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: __2_MAP,
		tagger: tagger,
		tree: bag
	}
});


// PIPE BAGS INTO EFFECT MANAGERS

function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		var fx = home in effectsDict
			? effectsDict[home]
			: { cmds: __List_Nil, subs: __List_Nil };

		__Scheduler_rawSend(managers[home], { $: 'fx', a: fx });
	}
}

function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case __2_LEAF:
			var home = bag.home;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.value);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case __2_NODE:
			var list = bag.branches;
			while (list.$ !== '[]')
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
				list = list.b;
			}
			return;

		case __2_MAP:
			_Platform_gatherEffects(isCmd, bag.tree, effectsDict, {
				tagger: bag.tagger,
				rest: taggers
			});
			return;
	}
}

function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		var temp = taggers;
		while (temp)
		{
			x = temp.tagger(x);
			temp = temp.rest;
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].cmdMap
		: _Platform_effectManagers[home].subMap;

	return A2(map, applyTaggers, value)
}

function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { cmds: __List_Nil, subs: __List_Nil };

	if (isCmd)
	{
		effects.cmds = __List_Cons(newEffect, effects.cmds);
		return effects;
	}
	effects.subs = __List_Cons(newEffect, effects.subs);
	return effects;
}


// PORTS

function _Platform_checkPortName(name)
{
	if (name in _Platform_effectManagers)
	{
		__Error_throw(3, name)
	}
}


// OUTGOING PORTS

function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		tag: 'cmd',
		cmdMap: _Platform_outgoingPortMap,
		converter: converter,
		isForeign: true
	};
	return _Platform_leaf(name);
}

var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });

function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].converter;

	// CREATE MANAGER

	var init = __Scheduler_succeed(null);

	function onEffects(router, cmdList, state)
	{
		while (cmdList.$ !== '[]')
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = converter(cmdList.a);
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
			cmdList = cmdList.b;
		}
		return init;
	}

	_Platform_effectManagers[name].init = init;
	_Platform_effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}


// INCOMING PORTS

function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		tag: 'sub',
		subMap: _Platform_incomingPortMap,
		converter: converter,
		isForeign: true
	};
	return _Platform_leaf(name);
}

var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});

function _Platform_setupIncomingPort(name, callback)
{
	var sentBeforeInit = [];
	var subs = __List_Nil;
	var converter = _Platform_effectManagers[name].converter;
	var currentOnEffects = preInitOnEffects;
	var currentSend = preInitSend;

	// CREATE MANAGER

	var init = __Scheduler_succeed(null);

	function preInitOnEffects(router, subList, state)
	{
		var postInitResult = postInitOnEffects(router, subList, state);

		for(var i = 0; i < sentBeforeInit.length; i++)
		{
			postInitSend(sentBeforeInit[i]);
		}

		sentBeforeInit = null; // to release objects held in queue
		currentSend = postInitSend;
		currentOnEffects = postInitOnEffects;
		return postInitResult;
	}

	function postInitOnEffects(router, subList, state)
	{
		subs = subList;
		return init;
	}

	function onEffects(router, subList, state)
	{
		return currentOnEffects(router, subList, state);
	}

	_Platform_effectManagers[name].init = init;
	_Platform_effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function preInitSend(value)
	{
		sentBeforeInit.push(value);
	}

	function postInitSend(value)
	{
		var temp = subs;
		while (temp.$ !== '[]')
		{
			callback(temp.a(value));
			temp = temp.b;
		}
	}

	function send(incomingValue)
	{
		var result = A2(__Json_run, converter, incomingValue);
		if (result.$ === 'Err')
		{
			__Error_throw(4, name, result.a);
		}

		currentSend(result.a);
	}

	return { send: send };
}
