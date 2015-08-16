Elm.Native.Trampoline = {};
Elm.Native.Trampoline.make = function(localRuntime) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Trampoline = localRuntime.Native.Trampoline || {};
	if (localRuntime.Native.Trampoline.values)
	{
		return localRuntime.Native.Trampoline.values;
	}

	// trampoline : Trampoline a -> a
	function trampoline(t)
	{
		var tramp = t;
		while (tramp.ctor === 'Continue')
		{
			tramp = tramp._0({ ctor: '_Tuple0' });
		}
		// tramp.ctor === 'Done'
		return tramp._0;
	}

	localRuntime.Native.Trampoline.values = {
		trampoline: trampoline
	};

	return localRuntime.Native.Trampoline.values;
};
