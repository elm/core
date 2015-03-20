Elm.Native.Port = {};
Elm.Native.Port.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Port = localRuntime.Native.Port || {};
	if (localRuntime.Native.Port.values)
	{
		return localRuntime.Native.Port.values;
	}

	var NS;
	var Task;
	var Utils = Elm.Native.Utils.make(localRuntime);


	// INTERNAL

	function port(name)
	{
		if (!NS)
		{
			NS = Elm.Native.Signal.make(localRuntime);
		}
		if (!Task)
		{
			Task = Elm.Native.Task.make(localRuntime);
		}

		var stream = NS.input(name);

		function send(value) {
			return Task.asyncFunction(function(callback) {
				localRuntime.setTimeout(function() {
					localRuntime.notify(stream.id, value);
				}, 0);
				callback(Task.succeed(Utils.Tuple0));
			});
		}

		return {
			_: {},
			stream: stream,
			address: {
				ctor: 'Address',
				_0: send
			}
		};
	}


	// INBOUND

	function inbound(name, type, converter)
	{
		var inboundPort = port(name);

		function send(jsValue)
		{
			try
			{
				var elmValue = converter(jsValue);
				Task.runOne(Task.spawn(inboundPort.send(elmValue)));
			}
			catch(e)
			{
				throw new Error(
					"Port Error:\n" +
					"Regarding the port named '" + name + "' with type:\n\n" +
					"    " + type.split('\n').join('\n        ') + "\n\n" +
					"You just sent the value:\n\n" +
					"    " + JSON.stringify(input.value) + "\n\n" +
					"but it cannot be converted to the necessary type.\n" +
					e.message
				));
			}
		}

		localRuntime.ports[name] = { send: send };

		return {
			_: {},
			stream: inboundPort.stream
		};
	}


	// OUTBOUND

	function outbound(name, converter)
	{
		var outboundPort = port(name);

		var subscribers = [];

		function subscribe(handler)
		{
			subscribers.push(handler);
		}
		function unsubscribe(handler)
		{
			subscribers.pop(subscribers.indexOf(handler));
		}

		function notify(elmValue)
		{
			var jsValue = converter(elmValue);
			var len = subscribers.length;
			for (var i = 0; i < len; ++i)
			{
				subscribers[i](jsValue);
			}
		}

		if (!NS)
		{
			NS = Elm.Native.Signal.make(localRuntime);
		}
		NS.output('output', notify, outboundPort.stream);

		localRuntime.ports[name] = {
			subscribe: subscribe,
			unsubscribe: unsubscribe
		};

		return {
			_: {},
			address: outboundPort.address
		};
	}


	return localRuntime.Native.Port.values = {
		port: port,
		inbound: inbound,
		outbound: outbound
	};
};
