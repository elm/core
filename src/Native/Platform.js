//import //

var _elm_lang$core$Native_Platform = function() {


// EFFECT MANAGERS

var managers = {};


// PROGRAMS

function addPublicModule(object, name, main)
{
	object['fullscreen'] = main ? fullscreenFor(main) : mainIsUndefined(name);
}

function mainIsUndefined(name)
{
	return function() {
		throw new Error(
			'Cannot initialize module ' + name +
			' because it has no `main` value! What would I run?'
		);
	};
}

function fullscreenFor(program)
{
	if (!program.renderer)
	{
		return function fullscreen()
		{
			_evancz$virtual_dom$Native_VirtualDom.staticProgram(document.body, program);
		}
	}

	return function fullscreen(flags)
	{
		var update = program.update;
		var subs = program.subscriptions;
		var view = program.view;

		var tuple = program.init(flags);
		var model = tuple._0;
		var renderer = program.renderer(document.body, enqueue, view(model));
		dispatchEffects(tuple._1, subs(model));

		function enqueue(msg)
		{
			// TODO this may be mean user events can "cut" to the front
			// of the event queue. If so, do it another way instead.
			var tuple = A2(update, msg, model);
			model = tuple._0;
			renderer.update(view(model));
			dispatchEffects(tuple._1, subs(model));
		}
	};
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

function dispatchEffects(cmdBag, subBag)
{
	var effectsDict = {};
	gatherEffects('cmd', cmdBag, effectsDict, null);
	gatherEffects('sub', subBag, effectsDict, null);

	for (var home in effectsDict)
	{
		var effects = effectsDict[home];
		var manager = managers[home];
		// TODO actually give the effects to the manager
	}
}

function gatherEffects(tag, bag, effectsDict, taggers)
{
	switch (bag.type)
	{
		case 'leaf':
			var home = bag.home;
			var effect = toEffect(home, taggers, bag.value);
			insert(tag, effectsDict, home, effect);
			return;

		case 'node':
			var list = bag.branches;
			while (list.ctor !== '[]')
			{
				gatherEffects(list._0, effectsDict, insert, taggers);
				list = list._1;
			}
			return;

		case 'map':
			gatherEffects(bag.tree, effectsDict, insert, {
				tagger: bag.tagger,
				rest: taggers
			});
			return;
	}
}

function insert(tag, effectsDict, home, value)
{
	var effects = effectsDict[home] || {
		'cmd': _elm_lang$core$Native_List.Nil,
		'sub': _elm_lang$core$Native_List.Nil
	};
	effects[tag] = _elm_lang$core$Native_List.Cons(value, effects[tag]);
	effectsDict[home] = effects;
}

function toEffect(tag, home, taggers, value)
{
	function applyTaggers(x)
	{
		var i = taggers.length;
		while (i--)
		{
			x = taggers[i](x);
		}
		return x;
	}

	return A2(managers[home][tag], applyTaggers, value)
}


return {
	managers: managers,
	addPublicModule: addPublicModule,
	leaf: leaf,
	batch: batch,
	map: map
};

}();