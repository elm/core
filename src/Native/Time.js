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


    function fpsWhen(desiredFPS, isOn) {
        var msPerFrame = 1000 / desiredFPS;
        var ticker = NS.input(true);

        // manage time deltas
        var initialState = {
            delta: 0,
            timestamp: localRuntime.timer.programStart
        };
        function updateState(event, old) {
            var curr = event._0;
            return {
                delta: event._1 ? 0 : curr - old.timestamp,
                timestamp: curr
            };
        }
        var state = A3( NS.fold, F2(updateState), initialState, NS.timestamp(ticker) );

        var deltas = A2( NS.map, function(p) { return p.delta; }, state );

        // turn ticker on and off depending on isOn signal
        var wasOn = true;
        var timeoutID = 0;
        function startStopTimer(isOn, t) {
            if (isOn)
            {
                timeoutID = localRuntime.setTimeout(function() {
                    localRuntime.notify(ticker.id, !wasOn && isOn); 
                }, msPerFrame);
            }
            else if (wasOn)
            {
                clearTimeout(timeoutID);
            }
            wasOn = isOn;
            return t;
        }

        return A3( NS.map2, F2(startStopTimer), isOn, deltas );
    }


    function every(t)
    {
        var ticker = NS.input(null);
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


    function read(s) {
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
