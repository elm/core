//import //

var _elm_lang$core$Native_Platform = function() {

function fullscreenFor(program)
{
	if (!program.renderer)
	{
		return function fullscreen()
		{
			_evancz$virtual_dom$Native_VirtualDom.render(document.body, program);
		}
	}

	return function fullscreen(flags)
	{
		var update = program.update;
		var subs = program.subscriptions;
		var view = program.view;

		var starterTuple = program.init(flags);
		var model = starterTuple._0;
		var initialCmds = starterTuple._1;  // TODO do these things
		var initialSubs = subs(model);      // TODO do these things

		var renderer = program.renderer(document.body, enqueue, view(model));

		function enqueue(msg)
		{
			// TODO this may be mean user events can "cut" to the front
			// of the event queue. If so, do it another way instead.
			model = A2(update, msg, model);
			renderer.update(view(model));
		}
	};
}

function mainIsUndefined(name)
{
	return function() {
		throw new Error('Cannot initialize module ' + name + ' because it has no `main` value! What would I run?')
	};
}

function addPublicModule(object, name, main)
{
	object['fullscreen'] = main ? fullscreenFor(main) : mainIsUndefined(name);
}

return {
	addPublicModule: addPublicModule
};

}();