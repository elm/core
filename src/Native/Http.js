Elm.Native.Http = {};
Elm.Native.Http.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Http = localRuntime.Native.Http || {};
    if (localRuntime.Native.Http.values)
    {
        return localRuntime.Native.Http.values;
    }

    var List = Elm.List.make(localRuntime);

    function send(verb, headers, url, mime, body, decoder) {
        return function(callback) {
            var request = window.ActiveXObject
                ? new ActiveXObject("Microsoft.XMLHTTP")
                : new XMLHttpRequest();
            request.onreadystatechange = function() {
                if (request.readyState === 4)
                {
                    if (request.status >= 200 && request.status < 300)
                    {
                        return callback('Ok', request.response);
                    }
                    return callback('Err', throw new Error('throw real error'));
                }
            }
            request.open(verb, url, true);
            function setHeader(pair) {
                request.setRequestHeader(pair._0, pair._1);
            }
            A2(List.map, setHeader, headers);
            if (mime.ctor === 'Just')
            {
                request.overrideMimeType(mime._0);
            }
            request.send(body.ctor === 'Just' ? body._0 : undefined);
        };
    }

    return localRuntime.Native.Http.values = {
        send: F6(send)
    };
};
