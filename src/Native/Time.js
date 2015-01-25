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

    function fst(pair) {
        return pair._0;
    }

    function fpsWhen(desiredFPS, isOn) {
        var msPerFrame = 1000 / desiredFPS;
        var ticker = NS.input(Utils.Tuple0);

        function notifyTicker() {
            localRuntime.notify(ticker.id, Utils.Tuple0);
        }

        var timeStampsTicker = A2( Signal.map, fst, NS.timestamp(ticker) );
        var timeStampedIsOn = NS.timestamp(Signal.dropRepeats(isOn));

        // turn ticker on and off depending on isOn signal
        var wasOn = isOn.value;
        var wasTime = localRuntime.timer.programStart;
        var timeoutID = 0;
        function startStopTimer(timeStampedIsOn, timestampTicker) {
            var delta = 0;
            if (timeStampedIsOn._1)
            {
                timeoutID = localRuntime.setTimeout(
                    notifyTicker,
                    msPerFrame
                );
                if (wasOn)
                {
                    delta = timestampTicker - wasTime;
                    wasTime = timestampTicker;
                }
                else
                {
                    wasOn = true;
                    wasTime = timeStampedIsOn._0;
                }
            }
            else if (wasOn)
            {
                clearTimeout(timeoutID);
                delta = timeStampedIsOn._0 - wasTime;
                wasOn = false;
            }
            return delta;
        }

        return A3( Signal.map2, F2(startStopTimer),
                   timeStampedIsOn,
                   timeStampsTicker );
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
