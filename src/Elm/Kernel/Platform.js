/*

import Elm.Kernel.Error exposing (throw)
import Elm.Kernel.Json exposing (run)
import Elm.Kernel.List exposing (Cons, Nil)
import Elm.Kernel.Scheduler exposing (andThen, binding, rawSend, rawSpawn, receive, send, succeed)
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
					impl.__$init,
					impl.__$update,
					impl.__$subscriptions,
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
					impl.__$init(result.a),
					impl.__$update,
					impl.__$subscriptions,
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
	var managers = {};
	var model = init.a;
	var view = renderer(sendToApp, model);

	function sendToApp(msg, viewMetadata)
	{
		var results = A2(update, msg, model);
		model = results.a;
		view(model, viewMetadata);
		_Platform_dispatchEffects(managers, results.b, subscriptions(model));
	}

	var ports = _Platform_setupEffects(managers, sendToApp);

	_Platform_dispatchEffects(managers, init.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}


// EFFECT MANAGERS

var _Platform_effectManagers = {};

function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.__portSetup)
		{
			ports = ports || {};
			ports[key] = manager.__portSetup(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}

function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		__init: init,
		__onEffects: onEffects,
		__onSelfMsg: onSelfMsg,
		__cmdMap: cmdMap,
		__subMap: subMap
	};
}

function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		__sendToApp: sendToApp,
		__selfProcess: undefined
	};

	var onEffects = info.__onEffects;
	var onSelfMsg = info.__onSelfMsg;
	var cmdMap = info.__cmdMap;
	var subMap = info.__subMap;

	function loop(state)
	{
		return A2(__Scheduler_andThen, loop, __Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === __2_SELF)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.__cmds, value.__subs, state)
				: A3(onEffects, router, cmdMap ? value.__cmds : value.__subs, state);
		}));
	}

	return router.__selfProcess = __Scheduler_rawSpawn(A2(__Scheduler_andThen, loop, info.__init));
}


// ROUTING

var _Platform_sendToApp = F2(function(router, msg)
{
	return __Scheduler_binding(function(callback)
	{
		router.__sendToApp(msg);
		callback(__Scheduler_succeed(__Utils_Tuple0));
	});
});

var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(__Scheduler_send, router.__selfProcess, {
		$: __2_SELF,
		a: msg
	});
});


// BAGS

function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: __2_LEAF,
			__home: home,
			__value: value
		};
	};
}

function _Platform_batch(list)
{
	return {
		$: __2_NODE,
		__bags: list
	};
}

var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: __2_MAP,
		__func: tagger,
		__bag: bag
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
		__Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || _Platform_noFx
		});
	}
}

var _Platform_noFx = { __cmds: __List_Nil, __subs: __List_Nil };

function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case __2_LEAF:
			var home = bag.__home;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.__value);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case __2_NODE:
			var list = bag.__bags;
			while (list.$ !== '[]')
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
				list = list.b;
			}
			return;

		case __2_MAP:
			_Platform_gatherEffects(isCmd, bag.__bag, effectsDict, {
				__tagger: bag.__func,
				__rest: taggers
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
			x = temp.__tagger(x);
			temp = temp.__rest;
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].__cmdMap
		: _Platform_effectManagers[home].__subMap;

	return A2(map, applyTaggers, value)
}

function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { __cmds: __List_Nil, __subs: __List_Nil };

	isCmd
		? (effects.__cmds = __List_Cons(newEffect, effects.__cmds))
		: (effects.__subs = __List_Cons(newEffect, effects.__subs));

	return effects;
}


// PORTS

function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		__Error_throw(3, name)
	}
}


// OUTGOING PORTS

function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		__cmdMap: _Platform_outgoingPortMap,
		__converter: converter,
		__portSetup: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}

var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });

function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].__converter;

	// CREATE MANAGER

	var init = __Scheduler_succeed(null);

	_Platform_effectManagers[name].__init = init;
	_Platform_effectManagers[name].__onEffects = F3(function(router, cmdList, state)
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
	});

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
		__subMap: _Platform_incomingPortMap,
		__converter: converter,
		__portSetup: _Platform_setupIncomingPort
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

function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = __List_Nil;
	var converter = _Platform_effectManagers[name].__converter;

	// CREATE MANAGER

	var init = __Scheduler_succeed(null);

	_Platform_effectManagers[name].__init = init;
	_Platform_effectManagers[name].__onEffects = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(__Json_run, converter, incomingValue);
		if (result.$ === 'Err')
		{
			__Error_throw(4, name, result.a);
		}

		var value = result.a;
		var temp = subs;
		while (temp.$ !== '[]')
		{
			sendToApp(temp.a(value));
			temp = temp.b;
		}
	}

	return { send: send };
}
