//import //

var _elm_lang$core$Native_Platform = function() {


// EFFECT MANAGERS

var globalManagerInfo = {};

function makeManager(info, mainProcess)
{
	var router = {
		main: mainProcess,
		self: undefined
	};

	var tag = info.tag;
	var onEffects = info.onEffects;
	var onSelfMsg = info.onSelfMsg;

	function onMessage(msg, state)
	{
		if (msg.ctor === 'self')
		{
			return A3(onSelfMsg, router, msg._0, state);
		}

		var fx = msg._0;
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

	var process = spawnLoop(info.init, onMessage);
	router.self = process;
	return process;
}

function sendToApp(router, msg)
{
	return A2(_elm_lang$core$Native_Scheduler.send, router.main, msg);
}

function sendToSelf(router, msg)
{
	return A2(_elm_lang$core$Native_Scheduler.send, router.self, {
		ctor: 'self',
		_0: msg
	});
}


// HELPER for STATEFUL LOOPS

function spawnLoop(init, onMessage)
{
	var andThen = _elm_lang$core$Native_Scheduler.andThen;

	function loop(state)
	{
		var handleMsg = _elm_lang$core$Native_Scheduler.receive(function(msg) {
			return onMessage(msg, state);
		});
		return A2(andThen, handleMsg, loop);
	}

	var task = A2(andThen, init, loop);

	return _elm_lang$core$Native_Scheduler.rawSpawn(task);
}


// PROGRAMS

function addPublicModule(object, name, main)
{
	var embed = main ? makeEmbed(name, main) : mainIsUndefined(name);

	object['embed'] = embed;

	object['fullscreen'] = function fullscreen(flags)
	{
		return embed(document.body, flags);
	};
}

function mainIsUndefined(name)
{
	return function(domNode)
	{
		var message = 'Cannot initialize module `' + name +
			'` because it has no `main` value!\nWhat should I show on screen?';
		domNode.innerHTML = errorHtml(message);
		throw new Error(message);
	};
}

function makeEmbed(moduleName, main)
{
	return function embed(rootDomNode, flags)
	{
		try
		{
			return makeEmbedHelp(moduleName, main, rootDomNode, flags);
		}
		catch (e)
		{
			rootDomNode.innerHTML = errorHtml(e.message);
			throw e;
		}
	};
}

function errorHtml(message)
{
	return '<div style="padding-left:1em;">'
		+ '<h2 style="font-weight:normal;"><b>Oops!</b> Something went wrong when starting your Elm program.</h2>'
		+ '<pre style="padding-left:1em;">' + message + '</pre>'
		+ '</div>';
}

function makeEmbedHelp(moduleName, main, rootDomNode, flags)
{
	// main is a union type with one of the following tags: vdom, no-flags, flags
	// the follow section figures out what to do in each case.
	if (main.ctor === 'vdom')
	{
		_elm_lang$virtual_dom$Native_VirtualDom.staticProgram(rootDomNode, main._0);
		return {};
	}

	// Define: init, update, subscriptions, view, and makeRenderer
	var program = main._0;
	var init = makeInit(moduleName, main);
	var update = program.update;
	var subscriptions = program.subscriptions;
	var view = program.view;
	var makeRenderer = program.renderer;

	// ambient state
	var managers = {};
	var renderer;

	// init and update state in main process
	var initApp = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		var results = init(flags);
		var model = results._0;
		renderer = makeRenderer(rootDomNode, enqueue, view(model));
		var cmds = results._1;
		var subs = subscriptions(model);
		dispatchEffects(managers, cmds, subs);
		callback(_elm_lang$core$Native_Scheduler.succeed(model));
	});

	function onMessage(msg, model)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
			var results = A2(update, msg, model);
			model = results._0;
			renderer.update(view(model));
			var cmds = results._1;
			var subs = subscriptions(model);
			dispatchEffects(managers, cmds, subs);
			callback(_elm_lang$core$Native_Scheduler.succeed(model));
		});
	}

	var mainProcess = spawnLoop(initApp, onMessage);

	function enqueue(msg)
	{
		_elm_lang$core$Native_Scheduler.rawSend(mainProcess, msg);
	}

	// setup all necessary effect managers
	for (var key in globalManagerInfo)
	{
		managers[key] = makeManager(globalManagerInfo[key], mainProcess);
	}

	// setup all foreign effects
	var foreign = {};
	var hasForeigns = false;

	for (var key in globalForeignCmds)
	{
		hasForeigns = true;
		setupCmd(key, managers, foreign);
	}

	for (var key in globalForeignSubs)
	{
		hasForeigns = true;
		setupSub(key, managers, foreign, mainProcess);
	}

	return hasForeigns ? { foreign: foreign } : {};
}

function makeInit(moduleName, main)
{
	var rawInit = main._0.init;

	if (main.ctor === 'no-flags')
	{
		return rawInit;
	}

	var flagDecoder = main._1;

	return function init(flags)
	{
		var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
		if (result.ctor === 'Err')
		{
			throw new Error('You trying to initialize module `' + moduleName + '` with unexpected flags.\n'
				+ 'When trying to convert the flags to a usable Elm value, I run into this problem:\n\n'
				+ result._0
			);
		}
		return rawInit(result._0);
	}
}


// BAGS

function leaf(home)
{
	return function(value)
	{
		return {
			type: 'leaf',
			home: home,
			value: value
		};
	};
}

function batch(list)
{
	return {
		type: 'node',
		branches: list
	};
}

function map(tagger, bag)
{
	return {
		type: 'map',
		tagger: tagger,
		tree: bag
	}
}


// PIPE BAGS INTO EFFECT MANAGERS

function dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	gatherEffects(true, cmdBag, effectsDict, null);
	gatherEffects(false, subBag, effectsDict, null);

	for (var home in effectsDict)
	{
		_elm_lang$core$Native_Scheduler.rawSend(managers[home], {
			ctor: 'fx',
			_0: effectsDict[home]
		});
	}
}

function gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.type)
	{
		case 'leaf':
			var home = bag.home;
			var effect = toEffect(isCmd, home, taggers, bag.value);
			effectsDict[home] = insert(isCmd, effect, effectsDict[home]);
			return;

		case 'node':
			var list = bag.branches;
			while (list.ctor !== '[]')
			{
				gatherEffects(isCmd, list._0, effectsDict, taggers);
				list = list._1;
			}
			return;

		case 'map':
			gatherEffects(isCmd, bag.tree, effectsDict, {
				tagger: bag.tagger,
				rest: taggers
			});
			return;
	}
}

function toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		while (taggers)
		{
			x = taggers.tagger(x);
			taggers = taggers.rest;
		}
		return x;
	}

	var map = isCmd
		? globalManagerInfo[home].cmdMap
		: globalManagerInfo[home].subMap;

	return A2(map, applyTaggers, value)
}

function insert(isCmd, newEffect, effects)
{
	effects = effects || {
		cmds: _elm_lang$core$Native_List.Nil,
		subs: _elm_lang$core$Native_List.Nil
	};
	if (isCmd)
	{
		effects.cmds = _elm_lang$core$Native_List.Cons(newEffect, effects.cmds);
		return effects;
	}
	effects.subs = _elm_lang$core$Native_List.Cons(newEffect, effects.subs);
	return effects;
}


// FOREIGN EFFECT LEAFS

var globalForeignCmds = {};
var globalForeignSubs = {};

function foreignCmd(name, converter)
{
	checkForeignName(name);
	globalForeignCmds[name] = converter;
	return leaf(name);
}

function foreignSub(name, converter)
{
	checkForeignName(name);
	globalForeignSubs[name] = converter;
	return leaf(name);
}

function checkForeignName(name)
{
	if (name in globalForeignCmds || name in globalForeignSubs)
	{
		throw new Error('There can only be one foreign effect named `'
			+ name + '`, but your program has multiple.');
	}
}


// SET UP FOREIGN EFFECTS

function setupCmd(name, managers, foreign)
{
	var converter = globalForeignCmds[name];
	var subs = [];


	// internal dispatching

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function onMessage(msg, state)
	{
		var cmdList = msg._0.cmds;

		while (cmdList.ctor !== '[]')
		{
			var value = converter(cmdList._0);

			for (var i = 0; i < subs.length; i++)
			{
				subs[i](value);
			}

			cmdList = cmdList._1;
		}

		return init;
	}

	managers[name] = spawnLoop(init, onMessage);
	globalManagerInfo[name] = { cmdMap: F2(foreignCmdMap) };


	// external subscriptions

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	foreign[name] = {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}

// setup foreign subscriptions
function setupSub(name, managers, foreign, mainProcess)
{
	var converter = globalForeignSubs[name];
	var subs = _elm_lang$core$Native_List.Nil;


	// internal

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function onMessage(msg, state)
	{
		subs = msg._0.subs;
		return init;
	}

	managers[name] = spawnLoop(init, onMessage);
	globalManagerInfo[name] = { subMap: F2(foreignSubMap) };


	// external

	function send(value)
	{
		var result = A2(_elm_lang$core$Json_Decode$decodeValue, converter, value);
		if (result.ctor === 'Err')
		{
			throw new Error('Trying to send an unexpected type of value through `' + name + '`:\n' + result._0);
		}

		var value = result._0;
		var temp = subs;
		while (temp.ctor !== '[]')
		{
			_elm_lang$core$Native_Scheduler.rawSend(mainProcess, temp._0(value));
			temp = temp._1;
		}
	}

	foreign[name] = { send: send };
}


// FOREIGN MAPS

function foreignCmdMap(tagger, value)
{
	return value;
}

function foreignSubMap(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
}


return {
	// routers
	sendToApp: F2(sendToApp),
	sendToSelf: F2(sendToSelf),

	// global setup
	globalManagerInfo: globalManagerInfo,
	addPublicModule: addPublicModule,

	// effect bags
	leaf: leaf,
	batch: batch,
	map: F2(map),
	foreignCmd: foreignCmd,
	foreignSub: foreignSub
};

}();