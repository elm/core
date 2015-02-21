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
		while(true)
		{
			switch(tramp.ctor)
			{
				case "Done":
					return tramp._0;
				case "Continue":
					tramp = tramp._0({ ctor: "_Tuple0" });
					continue;
			}
		}
	}

	return localRuntime.Native.Trampoline.values = {
		trampoline: trampoline
	};
};
