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

	return localRuntime.Native.Platform.values = {
		program: program
	};
};
