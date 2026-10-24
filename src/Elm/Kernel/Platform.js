/*

import Elm.Kernel.Debug exposing (crash)
import Elm.Kernel.Json exposing (run, wrap, unwrap, errorToString)
import Elm.Kernel.List exposing (Cons, Nil)
import Elm.Kernel.Process exposing (sleep)
import Elm.Kernel.Scheduler exposing (andThen, binding, enqueue, rawSend, rawSpawn, receive, send, succeed)
import Elm.Kernel.Utils exposing (Tuple0)
import Result exposing (isOk)

*/



// PROGRAMS


var _Platform_worker = F3(function(impl, flagDecoder, debugMetadata)
{
	var init = function(args)
	{
		return _Platform_initialize(
			flagDecoder,
			args,
			null,
			null,
			null,
			function() { return function() {} },
			impl
		);
	};

	/**__DEBUG/
	init.hotReloadData = {
		__$impl: impl,
		__$platform_effectManagers: _Platform_effectManagers
	};
	//*/

	return init;
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, _init, _update, _subscriptions, stepperBuilder, impl)
{
	// Old versions of elm/browser do not send the `impl` – instead, they send parts of it separately.
	// Sending the whole object is required for hot reloading.
	if (!impl)
	{
		impl = {
			__$init: _init,
			__$update: _update,
			__$subscriptions: _subscriptions
		};
	}

	var result = A2(__Json_run, flagDecoder, __Json_wrap(args ? args['flags'] : undefined));
	__Result_isOk(result) || __Debug_crash(2 /**__DEBUG/, __Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = impl.__$init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model, true);
	var ports = _Platform_setupEffects(managers, sendToApp);
	var stopped = false;

	function sendToApp(msg, viewMetadata)
	{
		if (stopped)
		{
			return;
		}
		var pair = A2(impl.__$update, msg, model);
		model = pair.a;
		_Platform_enqueueEffects(managers, pair.b, impl.__$subscriptions(model));
		stepper(model, viewMetadata);
	}

	// Apply `Cmd`s from `init`, and run `subscriptions` for the first time.
	_Platform_enqueueEffects(managers, initPair.b, impl.__$subscriptions(model));

	// Initial draw. This used to be done as a side effect of calling `stepperBuilder`.
	// `stepper.__$shutdown` was introduced at the same time as moving the draw call here,
	// so we can use that to know if we should draw or not. Drawing here has two benefits:
	// Firstly, it’s easier to understand. No hidden side effects. The effects are concentrated here.
	// Secondly, drawing can have side effects, because of custom elements. Their `connectedCallback`s
	// fire while drawing, and can dispatch (synchronous) events which cause an update. That won’t
	// work if the draw happened during `stepperBuilder`, since `stepper` won’t be defined here yet.
	if (stepper.__$shutdown)
	{
		stepper(model, true);
	}

	var detachedDomNode = undefined;
	var detaching = false;
	var detachCallbacks = [];

	var detachView = function(callback)
	{
		if (detachedDomNode !== undefined)
		{
			if (callback)
			{
				callback(detachedDomNode);
			}
			return;
		}

		if (callback)
		{
			detachCallbacks.push(callback);
		}

		// Repeated calls, including calls from custom element lifecycle callbacks,
		// share the same cleanup and final DOM node.
		if (detaching)
		{
			return;
		}
		detaching = true;

		var stepperShutdown = stepper.__$shutdown;

		// Draw synchronously one last time in case we’re waiting for an animation frame.
		// If a draw is already running, the animator finishes this draw request afterward.
		stepper(model, true);

		// Prevent new draw calls from being made.
		stepper = function() {};

		// Remove event listeners from the DOM.
		// This is only available in newer versions of elm/browser.
		// Also note that `_Platform_worker` does not provide it (since there’s no `view`).
		if (stepperShutdown)
		{
			stepperShutdown(didDetachView);
		}
		else
		{
			didDetachView(null);
		}
	};

	function didDetachView(domNode)
	{
		// Read the final root only after drawing and cleanup have finished.
		detachedDomNode = domNode;
		var callbacks = detachCallbacks;
		detachCallbacks = [];
		for (var i = 0; i < callbacks.length; i++)
		{
			callbacks[i](domNode);
		}
	}

	var stop = function(callback)
	{
		if (!stopped)
		{
			// Ignore messages immediately, including messages produced by the final draw
			// or by JavaScript in the completion callback.
			stopped = true;

			// Stop subscriptions.
			_Platform_enqueueEffects(managers, _Platform_batch(_List_Nil), _Platform_batch(_List_Nil));
		}

		detachView(callback);
	};

	var app = {
		detachView: detachView,
		stop: stop
	};

	if (ports)
	{
		app.ports = ports;
	}

	/**__DEBUG/
	// The effect manager definitions this app instance currently uses.
	// `_Platform_effectManagers` is shared by all app instances (and updated
	// by the first one to hot reload), so we can’t use it to tell what _this_
	// app instance needs to update.
	var effectManagers = {};
	for (var key in _Platform_effectManagers)
	{
		effectManagers[key] = _Platform_effectManagers[key];
	}

	app.hotReload = function(hotReloadData)
	{
		// In case the app was stopped during `Elm.hot.reload` (by another app being reloaded).
		// Otherwise we would set up subscriptions again below.
		if (stopped)
		{
			return;
		}

		// Remove old subscriptions.
		_Platform_enqueueEffects(managers, _Platform_batch(_List_Nil), _Platform_batch(_List_Nil));

		// Setup any new effect managers.
		var newPorts = _Platform_hotReloadEffects(managers, effectManagers, ports, hotReloadData.__$platform_effectManagers, sendToApp);
		if (!ports && newPorts)
		{
			app.ports = newPorts;
		}
		ports = newPorts;

		// Replace view, update and subscriptions with implementations from the new code.
		for (var key in hotReloadData.__$impl)
		{
			impl[key] = hotReloadData.__$impl[key];
		}

		// Set up new subscriptions.
		_Platform_enqueueEffects(managers, _Platform_batch(_List_Nil), impl.__$subscriptions(model));

		// Draw synchronously with the new view function.
		stepper(model, true);
	};
	//*/

	return app;
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
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
			var data = manager.__portSetup(key, sendToApp);
			ports[key] = data.__port;
			managers[key] = _Platform_instantiateManager(
				data.__init,
				data.__onEffects,
				null,
				manager.__cmdMap,
				manager.__subMap,
				sendToApp
			);
		}
		else
		{
			managers[key] = _Platform_instantiateManager(
				manager.__init,
				manager.__onEffects,
				manager.__onSelfMsg,
				manager.__cmdMap,
				manager.__subMap,
				sendToApp
			);
		}
	}

	return ports;
}


function _Platform_hotReloadEffects(managers, effectManagers, ports, newEffectManagers, sendToApp)
{
	for (var key in newEffectManagers)
	{
		var manager = newEffectManagers[key];
		var existing = effectManagers[key];

		if (manager.__portSetup)
		{
			// If a port already exists and is still outgoing or still incoming:
			if (existing && (manager.__cmdMap && existing.__cmdMap || manager.__subMap && existing.__subMap))
			{
				// Update its converter in case it has been changed to let different data through.
				existing.__converter = manager.__converter;
			}
			else
			{
				// Otherwise instantiate a new port. JavaScript already subscribed to the old port
				// won’t get any more data there (since the new Elm code never sends any).
				// JavaScript trying to send data through the old port won’t achieve anything,
				// since the new Elm code doesn’t have it in its subscriptions.
				effectManagers[key] = manager;
				_Platform_effectManagers[key] = manager;
				ports = ports || {};
				var data = manager.__portSetup(key, sendToApp);
				ports[key] = data.__port;
				managers[key] = _Platform_instantiateManager(
					data.__init,
					data.__onEffects,
					null,
					manager.__cmdMap,
					manager.__subMap,
					sendToApp
				);
			}
		}
		else if (!existing)
		{
			// Instantiate new, non-port effect managers.
			effectManagers[key] = manager;
			_Platform_effectManagers[key] = manager;
			managers[key] = _Platform_instantiateManager(
				manager.__init,
				manager.__onEffects,
				manager.__onSelfMsg,
				manager.__cmdMap,
				manager.__subMap,
				sendToApp
			);
		}
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


function _Platform_instantiateManager(init, onEffects, onSelfMsg, cmdMap, subMap, sendToApp)
{
	var router = {
		__sendToApp: sendToApp,
		__selfProcess: undefined
	};

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

	return router.__selfProcess = __Scheduler_rawSpawn(A2(__Scheduler_andThen, loop, init));
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
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


// Note: This is usually called together with `stepper`. We should enqueue effects _first,_
// since `stepper` (drawing) can cause `update` to be called again (via `connectedCallback`
// of custom elements), and it’s more expected if the first update’s commands are queued
// before the next.
function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ __managers: managers, __cmdBag: cmdBag, __subBag: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.__managers, fx.__cmdBag, fx.__subBag);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		__Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { __cmds: __List_Nil, __subs: __List_Nil }
		});
	}
}


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
			for (var list = bag.__bags; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
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
		for (var temp = taggers; temp; temp = temp.__rest)
		{
			x = temp.__tagger(x);
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
		__Debug_crash(3, name)
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
	var manager = _Platform_effectManagers[name];

	// CREATE MANAGER

	var init = __Process_sleep(0);

	var onEffects = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = __Json_unwrap(manager.__converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
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
		__init: init,
		__onEffects: onEffects,
		__port: {
			subscribe: subscribe,
			unsubscribe: unsubscribe
		}
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
	var manager = _Platform_effectManagers[name];

	// CREATE MANAGER

	var init = __Scheduler_succeed(null);

	var onEffects = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(__Json_run, manager.__converter, __Json_wrap(incomingValue));

		__Result_isOk(result) || __Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return {
		__init: init,
		__onEffects: onEffects,
		__port: { send: send }
	};
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export__PROD(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? __Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export__DEBUG(exports)
{
	// Remember that it is possible to have both `--optimize` and non-optimize scripts on the same page.
	// Scripts in `--optimize` define `Elm` but not `Elm.hot`.
	if (!scope['Elm'] || !scope['Elm'].hot)
	{
		// Use `defineProperty` to make `.hot` non-enumerable, so that a for-in loop on `scope['Elm']`
		// only includes Elm modules. We use that below, and end user code might depend on it too.
		scope['Elm'] = Object.defineProperty(scope['Elm'] || {}, 'hot', {
			value: {
				// Usage example:
				//     const f = new Function(newCompiledElmCodeAsString);
				//     const newScope = {};
				//     f.call(newScope);
				//     Elm.hot.reload(newScope);
				reload: function(newScope)
				{
					// Update Elm modules.
					_Platform_mergeExportsHotReload(scope['Elm'], newScope['Elm']);

					// Update hot reload data.
					for (var key in newScope['Elm'].hot.__hotReloadData)
					{
						scope['Elm'].hot.__hotReloadData[key] = newScope['Elm'].hot.__hotReloadData[key];
					}

					// Make the _new_ code push to the _old_ list of reload functions,
					// and read hot reload data from the _old_ dict (which is always merged with the latest above).
					var reloadFunctions = newScope['Elm'].hot.__reloadFunctions = scope['Elm'].hot.__reloadFunctions;
					newScope['Elm'].hot.__hotReloadData = scope['Elm'].hot.__hotReloadData;

					// Make the _new_ code use the scheduler from the _original_ code. It uses local state,
					// and the scheduling depends on there being a single queue.
					// Note: We use the original scheduler (rather than the latest), so that we don’t need to keep
					// reference to all hot reloaded versions of the code around (preventing garbage collection).
					newScope['Elm'].hot.__setSchedulerEnqueue(scope['Elm'].hot.__schedulerEnqueue);

					// Reload all running Elm app instances. Loop over a copy, since reloading an app draws,
					// and code running during drawing (custom elements) could stop an app, which removes
					// it from `reloadFunctions`. That would otherwise make us skip the next app.
					var currentReloadFunctions = reloadFunctions.slice();
					for (var i = 0; i < currentReloadFunctions.length; i++)
					{
						currentReloadFunctions[i]();
					}
				},
				__reloadFunctions: [],
				__hotReloadData: {},
				__schedulerEnqueue: __Scheduler_enqueue,
				__setSchedulerEnqueue: function(enqueue)
				{
					__Scheduler_enqueue = enqueue;
				}
			}
		});
	}
	else
	{
		// Another non-optimize script on the page has already created `Elm.hot`. Use the scheduler of that script,
		// since `Elm.hot.reload` points hot reloaded code to it (see above). Otherwise, the original code of this script
		// would use its own scheduler, while hot reloaded code of this script would use the other script’s scheduler.
		__Scheduler_enqueue = scope['Elm'].hot.__schedulerEnqueue;
	}

	_Platform_mergeExportsDebug('Elm', scope['Elm'], exports);
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		var exp = exports[name];
		if (name == 'init')
		{
			if (name in obj)
			{
				__Debug_crash(6, moduleName);
			}
			else if (exp.hotReloadData) // Older versions of elm/browser and elm/virtual-dom don’t provide this value.
			{
				obj[name] = _Platform_wrapInit(moduleName, exp);
				scope['Elm'].hot.__hotReloadData[moduleName] = exp.hotReloadData;
				delete exp.hotReloadData;
			}
			else
			{
				obj[name] = exp;
			}
		}
		else
		{
			_Platform_mergeExportsDebug(moduleName + '.' + name, obj[name] || (obj[name] = {}), exp);
		}
	}
}


function _Platform_mergeExportsHotReload(obj, exports)
{
	for (var name in exports)
	{
		(name in obj && name != 'init')
			? _Platform_mergeExportsHotReload(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_wrapInit(moduleName, init)
{
	return function(args)
	{
		var app = init(args);

		var hotReload = app.hotReload;
		delete app.hotReload;
		var reloadFunction = function()
		{
			hotReload(scope['Elm'].hot.__hotReloadData[moduleName]);
		};
		scope['Elm'].hot.__reloadFunctions.push(reloadFunction);

		var stop = app.stop;
		app.stop = function(callback)
		{
			var index = scope['Elm'].hot.__reloadFunctions.indexOf(reloadFunction);
			if (index !== -1)
			{
				scope['Elm'].hot.__reloadFunctions.splice(index, 1);
			}
			stop(callback);
		};

		return app;
	};
}
