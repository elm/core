Elm.Native.Keyboard = {};
Elm.Native.Keyboard.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Keyboard = localRuntime.Native.Keyboard || {};
	if (localRuntime.Native.Keyboard.values)
	{
		return localRuntime.Native.Keyboard.values;
	}

	var NS = Elm.Native.Signal.make(localRuntime);


	function keyEvent(event)
	{
		return {
			_: {},
			alt: event.altKey,
			meta: event.metaKey,
			keyCode: event.keyCode
		};
	}


	var downs = NS.input(null);

	localRuntime.addListener([downs.id], document, 'keydown', function down(e) {
		localRuntime.notify(downs.id, keyEvent(e));
	});


	var ups = NS.input(null);

	localRuntime.addListener([ups.id], document, 'keyup', function up(e) {
		localRuntime.notify(ups.id, keyEvent(e));
	});


	var presses = NS.input(null);

	localRuntime.addListener([downs.id], document, 'keypress', function press(e) {
		localRuntime.notify(press.id, keyEvent(e));
	});


	var blurs = NS.input(null);

	localRuntime.addListener([blurs.id], window, 'blur', function blur(e) {
		localRuntime.notify(blurs.id, null);
	});


	return localRuntime.Native.Keyboard.values = {
		downs: downs,
		ups: ups,
		blurs: blurs,
		presses: presses
	};

};
