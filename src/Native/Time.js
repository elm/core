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
        var ticker = NS.input(Utils.Tuple0);

        function notifyTicker() {
            localRuntime.notify(ticker.id, Utils.Tuple0);
        }

        function firstArg(x, y) { return x; }

        // input fires either when isOn changes, or when ticker fires.
        // Its value is a tuple with the current timestamp, and the state of isOn
        var input = NS.timestamp(A3(Signal.map2, F2(firstArg), Signal.dropRepeats(isOn), ticker));

        var wasOn = isOn.value;
        var timeoutId;
        var previousTime = localRuntime.timer.programStart;

        function update(obj) {
            var timestamp = obj._0;
            var isOn = obj._1;

            if (isOn)
            {
                timeoutId = localRuntime.setTimeout(notifyTicker, msPerFrame);
            }
            else
            {
                clearTimeout(timeoutId);
            }

            var delta = (isOn && !wasOn) ? 0 : timestamp - previousTime;
            wasOn = isOn;
            previousTime = timestamp;
            return delta;
        }

        return A2(Signal.map, update, input);
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
