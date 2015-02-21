Elm.Native.Ports = {};
Elm.Native.Ports.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Ports = localRuntime.Native.Ports || {};
	if (localRuntime.Native.Ports.values)
	{
		return localRuntime.Native.Ports.values;
	}

	var NS;

	function incomingSignal(converter)
	{
		converter.isSignal = true;
		return converter;
	}

	function outgoingSignal(converter)
	{
		return function(signal)
		{
			var subscribers = [];

			function subscribe(handler)
			{
				subscribers.push(handler);
			}
			function unsubscribe(handler)
			{
				subscribers.pop(subscribers.indexOf(handler));
			}

			function notify(value)
			{
				var val = converter(value);
				var len = subscribers.length;
				for (var i = 0; i < len; ++i)
				{
					subscribers[i](val);
				}
			}

			if (!NS)
			{
				NS = Elm.Native.Signal.make(localRuntime);
			}
			NS.output(notify, signal);

			return {
				subscribe: subscribe,
				unsubscribe: unsubscribe
			};
		};
	}

	function portIn(name, converter)
	{
		var jsValue = localRuntime.ports.incoming[name];
		if (jsValue === undefined)
		{
			throw new Error("Initialization Error: port '" + name +
							"' was not given an input!");
		}
		localRuntime.ports.uses[name] += 1;
		try
		{
			var elmValue = converter(jsValue);
		}
		catch(e)
		{
			throw new Error("Initialization Error on port '" + name + "': \n" + e.message);
		}

		// just return a static value if it is not a signal
		if (!converter.isSignal)
		{
			return elmValue;
		}

		// create a signal if necessary
		if (!NS)
		{
			NS = Elm.Native.Signal.make(localRuntime);
		}
		var signal = NS.input(elmValue);
		function send(jsValue)
		{
			try
			{
				var elmValue = converter(jsValue);
			}
			catch(e)
			{
				throw new Error("Error sending to port '" + name + "': \n" + e.message);
			}
			setTimeout(function() {
				localRuntime.notify(signal.id, elmValue);
			}, 0);
		}
		localRuntime.ports.outgoing[name] = { send:send };
		return signal;
	}

	function portOut(name, converter, value)
	{
		try
		{
			localRuntime.ports.outgoing[name] = converter(value);
		}
		catch(e)
		{
			throw new Error("Initialization Error on port '" + name + "': \n" + e.message);
		}
		return value;
	}

	return localRuntime.Native.Ports.values = {
		incomingSignal: incomingSignal,
		outgoingSignal: outgoingSignal,
		portOut: portOut,
		portIn: portIn
	};
};
