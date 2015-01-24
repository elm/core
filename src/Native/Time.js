Elm.Native.Time = {};
Elm.Native.Time.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Time = localRuntime.Native.Time || {};
    if (localRuntime.Native.Time.values) {
        return localRuntime.Native.Time.values;
    }

    var Signal = Elm.Signal.make(localRuntime);
    var NS = Elm.Native.Signal.make(localRuntime);
    var Maybe = Elm.Maybe.make(localRuntime);
    var Utils = Elm.Native.Utils.make(localRuntime);


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
        var state = A3( Signal.foldp, F2(updateState), initialState, NS.timestamp(ticker) );

        var deltas = A2( Signal.map, function(p) { return p.delta; }, state );

        var wasOn = isOn.value;
        var timeoutID = 0;

        function notifyAndForceDeltaToZero() {
            localRuntime.notify(ticker.id, true);
        }

        function notifyAndUseActualDelta() {
            localRuntime.notify(ticker.id, false);
        }

        // turn ticker on and off depending on isOn signal
        function startStopTimer(isOn, t) {
            if (isOn)
            {
                timeoutID = localRuntime.setTimeout(
                    wasOn ? notifyAndUseActualDelta
                          : notifyAndForceDeltaToZero,
                    msPerFrame
                );
            }
            else if (wasOn)
            {
                clearTimeout(timeoutID);
            }
            wasOn = isOn;
            return t;
        }

        return A3( Signal.map2, F2(startStopTimer), isOn, deltas );
    }


    function fps(t) {
        return fpsWhen(t, Signal.constant(true));
    }


    function every(t) {
      var ticker = NS.input(Utils.Tuple0);
      function tellTime() {
          localRuntime.notify(ticker.id, Utils.Tuple0);
      }
      var clock = A2( Signal.map, fst, NS.timestamp(ticker) );
      setInterval(tellTime, t);
      return clock;
    }


    function fst(pair) {
        return pair._0;
    }


    function read(s) {
        var t = Date.parse(s);
        return isNaN(t) ? Maybe.Nothing : Maybe.Just(t);
    }

    return localRuntime.Native.Time.values = {
        fpsWhen: F2(fpsWhen),
        fps: fps,
        every: every,
        delay: NS.delay,
        timestamp: NS.timestamp,
        toDate: function(t) { return new window.Date(t); },
        read: read
    };

};
