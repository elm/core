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

		if (manager.portSetup)
		{
			ports = ports || {};
			ports[key] = manager.portSetup(key, sendToApp);
		}

		managers[key] = _Platform_makeManager(manager, sendToApp);
	}

	return ports;
}

function _Platform_makeManager(info, sendToApp)
{
	var router = {
		main: sendToApp,
		self: undefined
	};

	var tag = info.tag;
	var onEffects = info.onEffects;
	var onSelfMsg = info.onSelfMsg;

	function loop(state)
	{
		return A2(__Scheduler_andThen, loop, __Scheduler_receive(function(msg)
		{
			if (msg.$ === __2_SELF)
			{
				return A3(onSelfMsg, router, msg.a, state);
			}

			var fx = msg.a;
			return tag === 'fx'
				? A4(onEffects, router, fx.cmds, fx.subs, state)
				: A3(onEffects, router, tag === 'cmd' ? fx.cmds : fx.subs, state);
		}));
	}

	return router.self = __Scheduler_rawSpawn(A2(__Scheduler_andThen, loop, info.init));
}


// ROUTING

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


// BAGS

function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: __2_LEAF,
			a: home,
			b: value
		};
	};
}

function _Platform_batch(list)
{
	return {
		$: __2_NODE,
		a: list
	};
}

var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: __2_MAP,
		a: tagger,
		b: bag
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

var _Platform_noFx = { cmds: __List_Nil, subs: __List_Nil };

function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case __2_LEAF:
			var home = bag.a;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.b);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case __2_NODE:
			var list = bag.a;
			while (list.$ !== '[]')
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
				list = list.b;
			}
			return;

		case __2_MAP:
			_Platform_gatherEffects(isCmd, bag.b, effectsDict, {
				tagger: bag.a,
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

	isCmd
		? (effects.cmds = __List_Cons(newEffect, effects.cmds))
		: (effects.subs = __List_Cons(newEffect, effects.subs));

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
		tag: 'cmd',
		cmdMap: _Platform_outgoingPortMap,
		converter: converter,
		portSetup: _Platform_setupOutgoingPort
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

	_Platform_effectManagers[name].init = init;
	_Platform_effectManagers[name].onEffects = F3(function(router, cmdList, state)
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
		tag: 'sub',
		subMap: _Platform_incomingPortMap,
		converter: converter,
		portSetup: _Platform_setupIncomingPort
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
	var converter = _Platform_effectManagers[name].converter;

	// CREATE MANAGER

	var init = __Scheduler_succeed(null);

	_Platform_effectManagers[name].init = init;
	_Platform_effectManagers[name].onEffects = F3(function(router, subList, state)
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
