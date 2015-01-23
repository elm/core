Elm.Native.WebSocket = {};
Elm.Native.WebSocket.make = function(localRuntime) {

  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.WebSocket = localRuntime.Native.WebSocket || {};
  if (localRuntime.Native.WebSocket.values)
  {
      return localRuntime.Native.WebSocket.values;
  }

  var Signal = Elm.Signal.make(localRuntime);
  var NS = Elm.Native.Signal.make(localRuntime);
  var List = Elm.Native.List.make(localRuntime);

  function open(url, outgoing) {
    var incoming = NS.input("");
    var ws = new WebSocket(url);

    var pending = [];
    var ready = false;
    
    ws.onopen = function(e) {
      var len = pending.length;
      for (var i = 0; i < len; ++i) { ws.send(pending[i]); }
      ready = true;
    };
    ws.onmessage = function(event) {
      localRuntime.notify(incoming.id, event.data);
    };
    
    function send(msg) {
      ready ? ws.send(msg) : pending.push(msg);
    }
    
    function take1(x,y) { return x }
    return A3(Signal.map2, F2(take1), incoming, A2(Signal.map, send, outgoing));
  }

  return localRuntime.Native.WebSocket.values = { connect: F2(open) };
};
