Elm.Native.Time = {};
Elm.Native.Time.make = function(elm) {

  elm.Native = elm.Native || {};
  elm.Native.Time = elm.Native.Time || {};
  if (elm.Native.Time.values) return elm.Native.Time.values;

  var Signal = Elm.Signal.make(elm);
  var NS = Elm.Native.Signal.make(elm);
  var Maybe = Elm.Maybe.make(elm);
  var Utils = Elm.Native.Utils.make(elm);

  function fpsWhen(desiredFPS, isOn) {
    var msPerFrame = 1000 / desiredFPS;
    var wasOn = true;
    var ticker = NS.input(true);
    var timeoutID = 0;
    function startStopTimer(isOn, t) {
      if (isOn) {
        timeoutID = elm.setTimeout( function() {
                                      elm.notify(ticker.id, !wasOn && isOn); 
                                    }
                                  , msPerFrame
                                  );
      } else if (wasOn) {
        clearTimeout(timeoutID);
      }
      wasOn = isOn;
      return t;
    }
    function calcDelta(event, old) {
      var curr = event._0;
      return { delta: event._1 ? 0 : curr - old.timestamp, timestamp: curr };
    }
    var deltas = A2( Signal.map
                   , function(p) {
                       return p.delta;
                     }
                   , A3( Signal.foldp
                       , F2(calcDelta)
                       , { delta: 0, timestamp: elm.timer.programStart }
                       , NS.timestamp(ticker)
                       )
                   );
    return A3( Signal.map2, F2(startStopTimer), isOn, deltas );
  }

  function fst(pair) {
      return pair._0;
  }

  function every(t) {
    var ticker = NS.input(Utils.Tuple0);
    function tellTime() {
        elm.notify(ticker.id, Utils.Tuple0);
    }
    var clock = A2( Signal.map, fst, NS.timestamp(ticker) );
    setInterval(tellTime, t);
    return clock;
  }

  function read(s) {
      var t = Date.parse(s);
      return isNaN(t) ? Maybe.Nothing : Maybe.Just(t);
  }
  return elm.Native.Time.values = {
      fpsWhen : F2(fpsWhen),
      fps : function(t) { return fpsWhen(t, Signal.constant(true)); },
      every : every,
      delay : NS.delay,
      timestamp : NS.timestamp,
      toDate : function(t) { return new window.Date(t); },
      read   : read
  };

};
