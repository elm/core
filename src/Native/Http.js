Elm.Native.Http = {};
Elm.Native.Http.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Http = localRuntime.Native.Http || {};
    if (localRuntime.Native.Http.values)
    {
        return localRuntime.Native.Http.values;
    }

    var Dict = Elm.Dict.make(localRuntime);
    var List = Elm.List.make(localRuntime);
    var Maybe = Elm.Maybe.make(localRuntime);
    var Promise = Elm.Native.Promise.make(localRuntime);


    function send(settings, request) {
        return Promise.asyncFunction(function(callback) {
            var req = new XMLHttpRequest();

            // start
            if (settings.onStart.ctor === 'Just')
            {
                req.addEventListener('loadStart', function() {
                    var promise = settings.onStart._0;
                    Promise.spawn(promise);
                });
            }

            // progress
            if (settings.onProgress.ctor === 'Just')
            {
                req.addEventListener('progress', function(event) {
                    var progress = {
                        _: {},
                        lengthComputable: event.lengthComputable,
                        loaded: event.loaded,
                        total: event.total
                    };
                    var promise = settings.onProgress._0(progress);
                    Promise.spawn(promise);
                });
            }

            // end
            req.addEventListener('error', function() {
                return callback(Promise.fail({ ctor: 'NetworkError' }));
            });

            req.addEventListener('timeout', function() {
                return callback(Promise.fail({ ctor: 'Timeout' }));
            });

            req.addEventListener('load', function() {
                return callback(Promise.succeed(toResponse(req)));
            });

            req.open(request.verb, request.url, true);

            // set all the headers
            function setHeader(pair) {
                req.setRequestHeader(pair._0, pair._1);
            }
            A2(List.map, setHeader, request.headers);

            // set the timeout
            req.timeout = settings.timeout;

            // ask for a specific MIME type for the response
            if (settings.desiredResponseType.ctor === 'Just')
            {
                req.overrideMimeType(settings.desiredResponseType._0);
            }

            req.send(request.body);
        });
    }


    // deal with responses

    function toResponse(req) {
        var tag = typeof req.response === 'string' ? 'Text' : 'Blob';
        return {
            _: {},
            status: req.status,
            statusText: req.statusText,
            headers: parseHeaders(req.getAllResponseHeaders()),
            url: req.responseURL,
            value: { ctor: tag, _0: req.response }
        };
    }


    function parseHeaders(rawHeaders) {
        var headers = Dict.empty;

        if (!rawHeaders)
        {
            return headers;
        }

        var headerPairs = rawHeaders.split('\u000d\u000a');
        for (var i = headerPairs.length; i--; )
        {
            var headerPair = headerPairs[i];
            var index = headerPair.indexOf('\u003a\u0020');
            if (index > 0)
            {
                var key = headerPair.substring(0, index);
                var value = headerPair.substring(index + 2);
                
                headers = A3(Dict.update, key, function(oldValue) {
                    if (oldValue.ctor === 'Just')
                    {
                        return Maybe.Just(value + ', ' + oldValue._0);
                    }
                    return Maybe.Just(value);
                }, headers);
            }
        }

        return headers;
    }


    function multipart(dataList) {
        var formData = new FormData();

        while (dataList.ctor !== '[]')
        {
            var data = dataList._0;
            if (type === 'StringData')
            {
                formData.append(data._0, data._1);
            }
            else
            {
                formData.append(data._0, data._2, data._1);
            }
            dataList = dataList._1;
        }

        return { ctor: 'FormData', formData: formData };
    }


    return localRuntime.Native.Http.values = {
        send: F2(send),
        multipart: multipart
    };
};
