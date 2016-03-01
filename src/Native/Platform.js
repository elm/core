//import //

var _elm_lang$core$Native_Platform = function() {


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
		var initialCmds = categorizeEffects(tuple._1);
		var initialSubs = categorizeEffects(subs(model));

		var renderer = program.renderer(document.body, enqueue, view(model));

		function enqueue(msg)
		{
			// TODO this may be mean user events can "cut" to the front
			// of the event queue. If so, do it another way instead.
			var tuple = A2(update, msg, model);
			model = tuple._0;
			categorizeEffects(tuple._1);
			renderer.update(view(model));
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

function categorizeEffects(bag)
{
	return categorizeEffectsHelp(bag, {});
}

function categorizeEffectsHelp(bag, effectDict)
{
	switch (bag.type)
	{
		case 'leaf':
			var home = bag.home;
			var effects = effectDict[home];

			var value = {
				effect: bag.value,
				taggers: []
			};

			effects
				? effects.push(value)
				: effectDict[home] = [value];

			return effectDict;

		case 'node':
			var list = bag.branches;
			while (list.ctor !== '[]')
			{
				categorizeEffectsHelp(list._0, effectDict);
				list = list._1;
			}
			return effectDict;

		case 'map':
			categorizeEffectsHelp(bag.tree, effectDict);
			for (var home in effectDict)
			{
				var effects = effectDict[home];
				for (var i = 0; i < effects.length; i++)
				{
					var effect = effects[i];
					effect.taggers.push(bag.tagger);
				}
			}
			return effectDict;
	}
}


return {
	addPublicModule: addPublicModule,
	leaf: leaf,
	batch: batch,
	map: map
};

}();