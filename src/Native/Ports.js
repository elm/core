Elm.Native.Ports = {};
Elm.Native.Ports.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Ports = localRuntime.Native.Ports || {};
	if (localRuntime.Native.Ports.values)
	{
		return localRuntime.Native.Ports.values;
	}

	var NS;
	var Promise;
	var Utils = Elm.Native.Utils.make(localRuntime);


	// WRITABLE STREAMS

	function mailbox(name)
	{
		if (!NS)
		{
			NS = Elm.Native.Signal.make(localRuntime);
		}
		if (!Promise)
		{
			Promise = Elm.Native.Promise.make(localRuntime);
		}

		var stream = NS.input(name);

		function send(value) {
			return Promise.asyncFunction(function(callback) {
				localRuntime.setTimeout(function() {
					localRuntime.notify(stream.id, value);
				}, 0);
				callback(Promise.succeed(Utils.Tuple0));
			});
		}

		return {
			stream: stream,
			address: {
				ctor: 'Address',
				_0: send
			}
		};
	}

	var loopbackInputs = {};

	function loopbackOut(name, promises)
	{
		if (!Promise)
		{
			Promise = Elm.Native.Promise.make(localRuntime);
		}
		return Promise.runStream(name, promises, function(result) {
			localRuntime.notify(loopbackInputs[name].id, result);
		});
	}

	function loopbackIn(name)
	{
		if (!NS)
		{
			NS = Elm.Native.Signal.make(localRuntime);
		}
		var results = NS.input('loopback-' + name + '-results');
		loopbackInputs[name] = results;
		return results;
	}


	// INPUTS

	function inputValue(name, type, converter)
	{
		return initialValue(name, type, converter);
	}

	function inputStream(name, type, converter)
	{
		var input = setupSendSignal(name, type, converter);
		localRuntime.foreignInput[name] = { send: input.send };
		return input.signal;
	}

	function inputVarying(name, type, converter)
	{
		var value = initialValue(name, type, converter);
		var input = setupSendSignal(name, type, converter, value);
		localRuntime.foreignInput[name] = { send: input.send };
		return input.signal;
	}

	function setupSendSignal(name, type, converter, initialValue)
	{
		if (!NS)
		{
			NS = Elm.Native.Signal.make(localRuntime);
		}
		var signal = NS.input(name, initialValue);

		function send(jsValue)
		{
			try
			{
				var elmValue = converter(jsValue);
			}
			catch(e)
			{
				throw new Error(inputError(name, type,
					"You just sent the value:\n\n" +
					"    " + JSON.stringify(input.value) + "\n\n" +
					"but it cannot be converted to the necessary type.\n" +
					e.message
				));
			}
			setTimeout(function() {
				localRuntime.notify(signal.id, elmValue);
			}, 0);
		}

		return {
			send: send,
			signal: signal
		};
	}

	function initialValue(name, type, converter)
	{
		var nameExists = name in localRuntime.givenInputs;

		if (!nameExists)
		{
			throw new Error(inputError(name, type,
				"You must provide an initial value! Something like this in JS:\n\n" +
				"    Elm.fullscreen(Elm.MyModule, { " + name + ": ... });"
			));
		}

		var input = localRuntime.givenInputs[name];
		input.used = true;

		try
		{
			return converter(input.value);
		}
		catch(e)
		{
			throw new Error(inputError(name, type,
				"You gave an initial value of:\n\n" +
				"    " + JSON.stringify(input.value) + "\n\n" +
				"but it cannot be converted to the necessary type.\n" +
				e.message
			));
		}
	}

	function inputError(name, type, message)
	{
		return "Input Error:\n" +
			"Regarding the input named '" + name + "' with type:\n\n" +
			"    " + type.split('\n').join('\n        ') + "\n\n" +
			message;
	}


	// OUTPUTS

	function outputValue(name, converter, value)
	{
		localRuntime.foreignOutput[name] = converter(value);
		return value;
	}

	function outputStream(name, converter, value)
	{
		localRuntime.foreignOutput[name] = setupSubscription(converter, value);
		return value;
	}

	function outputVarying(name, converter, value)
	{
		localRuntime.foreignOutput[name] = setupSubscription(converter, value);
		return value;
	}

	function setupSubscription(converter, signal)
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
		NS.output('output', notify, signal);

		return {
			subscribe: subscribe,
			unsubscribe: unsubscribe
		};
	}


	return localRuntime.Native.Ports.values = {
		inputValue: inputValue,
		inputStream: inputStream,
		inputVarying: inputVarying,
		outputValue: outputValue,
		outputStream: outputStream,
		outputVarying: outputVarying,
		mailbox: mailbox,
		loopbackIn: loopbackIn,
		loopbackOut: loopbackOut
	};
};
