Elm.Native.Platform = {};
Elm.Native.Platform.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Platform = localRuntime.Native.Platform || {};
	if (localRuntime.Native.Platform.values)
	{
		return localRuntime.Native.Platform.values;
	}

	function program(details)
	{
		return details;
	}

	function dummyRenderer(parent, tagger, initialUnit)
	{
		return {
			update: function(newUnit) {}
		};
	}

	return localRuntime.Native.Platform.values = {
		program: program,
		dummyRenderer: dummyRenderer
	};
};
