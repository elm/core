Elm.Native.Debug = {};
Elm.Native.Debug.make = function(elm) {
    elm.Native = elm.Native || {};
    elm.Native.Debug = elm.Native.Debug || {};
    if (elm.Native.Debug.values)
    {
        return elm.Native.Debug.values;
    }

    var toString = Elm.Native.Show.make(elm).toString;

    function log(tag, value)
    {
        var msg = tag + ': ' + toString(value);
        var process = process || {};
        if (process.stdout) {
            process.stdout.write(msg);
        } else {
            console.log(msg);
        }
        return value;
    }

    function crash(message)
    {
        throw new Error(message);
    }

    function tracePath(tag, form)
    {
        if (elm.debug)
        {
            return elm.debug.trace(tag, form);
        }
        return form;
    }

    function watch(tag, value)
    {
        if (elm.debug)
        {
            elm.debug.watch(tag, value);
        }
        return value;
    }

    function watchSummary(tag, summarize, value)
    {
        if (elm.debug)
        {
            elm.debug.watch(tag, summarize(value));
        }
        return value;
    }

    return elm.Native.Debug.values = {
        crash: crash,
        tracePath: F2(tracePath),
        log: F2(log),
        watch: F2(watch),
        watchSummary:F3(watchSummary),
    };
};
