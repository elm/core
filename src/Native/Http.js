Elm.Native.Http = {};
Elm.Native.Http.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Http = localRuntime.Native.Http || {};
    if (localRuntime.Native.Http.values)
    {
        return localRuntime.Native.Http.values;
    }

    var List = Elm.List.make(localRuntime);
    var Signal = Elm.Signal.make(localRuntime);

    function registerReq(queue,responses) {
        return function(req) {
            if (req.url.length > 0)
            {
                sendReq(queue,responses,req);
            }
        };
    }

    function updateQueue(queue,responses) {
        if (queue.length > 0)
        {
            localRuntime.notify(responses.id, queue[0].value);
            if (queue[0].value.ctor !== 'Waiting')
            {
                queue.shift();
                setTimeout(function() { updateQueue(queue,responses); }, 0);
            }
        }
    }

    function sendReq(queue,responses,req) {
        var response = { value: { ctor:'Waiting' } };
        queue.push(response);

        var request = (window.ActiveXObject
                       ? new ActiveXObject("Microsoft.XMLHTTP")
                       : new XMLHttpRequest());

        request.onreadystatechange = function(e) {
            if (request.readyState === 4)
            {
                response.value = (request.status >= 200 && request.status < 300 ?
                                  { ctor:'Success', _0:request.responseText } :
                                  { ctor:'Failure', _0:request.status, _1:request.statusText });
                setTimeout(function() { updateQueue(queue,responses); }, 0);
            }
        };
        request.open(req.verb, req.url, true);
        function setHeader(pair) {
            request.setRequestHeader( pair._0, pair._1 );
        }
        A2( List.map, setHeader, req.headers );
        request.send(req.body);
    }

    function send(requests) {
        var responses = Signal.constant(localRuntime.Http.values.Waiting);
        var sender = A2( Signal.map, registerReq([],responses), requests );
        function f(x) { return function(y) { return x; } }
        return A3( Signal.map2, f, responses, sender );
    }

    return localRuntime.Native.Http.values = {
        send:send
    };
};
