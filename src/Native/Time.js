Elm.Native.Time = {};
Elm.Native.Time.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Time = localRuntime.Native.Time || {};
	if (localRuntime.Native.Time.values)
	{
		return localRuntime.Native.Time.values;
	}

	var NS = Elm.Native.Signal.make(localRuntime);
	var Maybe = Elm.Maybe.make(localRuntime);


	// FRAMES PER SECOND

	function fpsWhen(desiredFPS, isOn)
	{
		var msPerFrame = 1000 / desiredFPS;
		var ticker = NS.input('fpsWhen', null);

		function notifyTicker()
		{
			localRuntime.notify(ticker.id, null);
		}

		var onOffEvents = A2(NS.streamMap, onOff, isOn);
		var events = A3(NS.genericMerge, F2(firstArg), onOffEvents, ticker);
		var timestampedEvents = NS.timestamp(events);

		var emptyState = {
			isOn: isOn.initialValue,
			time: localRuntime.timer.programStart,
			delta: null
		};

		var timeoutId = 0;

		if (emptyState.isOn)
		{
			timeoutId = localRuntime.setTimeout(notifyTicker, msPerFrame);
		}

		function fpsUpdate(rawEvent, state)
		{
			var currentTime = rawEvent._0;
			var event = rawEvent._1;

			if (state.isOn && event === null)
			{
				timeoutId = localRuntime.setTimeout(notifyTicker, msPerFrame);
				return {
					isOn: true,
					time: currentTime,
					delta: currentTime - state.time
				};
			}
			else if (!state.isOn && event !== null && event._0)
			{
				timeoutId = localRuntime.setTimeout(notifyTicker, msPerFrame);
				return {
					isOn: true,
					time: currentTime,
					delta: null
				};
			}
			else if (state.isOn && event !== null && !event._0)
			{
				clearTimeout(timeoutId);
				return {
					isOn: false,
					time: currentTime, // irrelevant
					delta: currentTime - state.time
				};
			}
			return {
				isOn: state.isOn,
				time: state.time, // only relevant if isOn is true
				delta: null
			};
		}
		var state = A3(NS.fold, F2(fpsUpdate), emptyState, timestampedEvents);
		return A2(NS.filterMap, toDelta, state);
	}

	function onOff(isOn)
	{
		return {
			ctor: 'OnOff',
			_0: isOn
		};
	}

	function toDelta(state)
	{
		if (state.delta !== null)
		{
			return Maybe.Just(state.delta);
		}
		return Maybe.Nothing;
	}

	function firstArg(x,y)
	{
		return x;
	}


	// EVERY

	function every(t)
	{
		var ticker = NS.input('every', null);
		function tellTime()
		{
			localRuntime.notify(ticker.id, null);
		}
		var clock = A2( NS.map, fst, NS.timestamp(ticker) );
		setInterval(tellTime, t);
		return clock;
	}


	function fst(pair)
	{
		return pair._0;
	}


	function read(s)
	{
		var t = Date.parse(s);
		return isNaN(t) ? Maybe.Nothing : Maybe.Just(t);
	}

	return localRuntime.Native.Time.values = {
		fpsWhen: F2(fpsWhen),
		every: every,
		toDate: function(t) { return new window.Date(t); },
		read: read
	};

};
