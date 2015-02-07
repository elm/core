Elm.Native.Http = {};
Elm.Native.Http.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Http = localRuntime.Native.Http || {};
    if (localRuntime.Native.Http.values)
    {
        return localRuntime.Native.Http.values;
    }

    var List = Elm.List.make(localRuntime);
    var Promise = Elm.Native.Promise.make(localRuntime);


    function send(settings, request) {
        return Promise.asyncFunction(function(callback) {
            var req = new XMLHttpRequest();

            // monitor progress
            req.onreadystatechange = function() {
                if (req.readyState === 4)
                {
                    if (req.status >= 200 && req.status < 300)
                    {
                        var headers = req.getAllResponseHeaders();
                        return callback(Promise.succeed(req.response));
                    }
                    return callback(Promise.fail(throw 'figure out error type'));
                }
            }

            if (settings.onStart.ctor === 'Just')
            {
                req.addEventListener('loadStart', function() {
                    Promise.runPromise(settings.onStart._0);
                });
            }

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
                    Promise.runPromise(promise);
                });
            }

            req.open(request.verb, request.url, true);

            // set all the headers
            function(pair) {
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

        return formData;
    }


    return localRuntime.Native.Http.values = {
        send: F6(send),
        multipart: multipart
    };
};
