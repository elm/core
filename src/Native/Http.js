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
            var request = new XMLHttpRequest();
            request.onreadystatechange = function() {
                if (request.readyState === 4)
                {
                    if (request.status >= 200 && request.status < 300)
                    {
                        var headers = request.getAllResponseHeaders();
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
