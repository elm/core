Elm.Native.Promise = {};
Elm.Native.Promise.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Promise = localRuntime.Native.Promise || {};
    if (localRuntime.Native.Promise.values)
    {
        return localRuntime.Native.Promise.values;
    }

    var DEPTH_LIMIT = 100;

    function succeed(value)
    {
        return {
            tag: 'Succeed',
            value: value
        };
    }

    function fail(error)
    {
        return {
            tag: 'Fail',
            value: error
        };
    }

    function asyncFunction(func)
    {
        return {
            tag: 'Async',
            asyncFunction: func
        };
    }

    function andThen(promise, callback)
    {
        return {
            tag: 'AndThen',
            promise: promise,
            callback: callback
        };
    }

    function catch_(promise, callback)
    {
        return {
            tag: 'Catch',
            promise: promise,
            callback: callback
        };
    }


    // RUNNER

    function run(initialValue, promiseSignal)
    {
        var resultSignal = Signal.input(initialValue);
        var workQueue = [];

        function register(promise) {
            var root = { promise: promise };
            workQueue.push(root);
            startPromise(resultSignal, workQueue, root);
        }

        A2(Signal.map, register, promiseSignal);

        return resultSignal;
    }

    function updateWorkQueue(resultSignal, workQueue)
    {
        while (workQueue.length > 0 && workQueue[0].result)
        {
            localRuntime.notify(resultSignal.id, workQueue[0].result);
            workQueue.shift();
        }
    }

    function mark(status, promise)
    {
        return { status: status, promise: promise };
    }

    function startPromise(resultSignal, workQueue, root)
    {
        var result = runnable(root.promise);
        while (result.status === 'runnable')
        {
            result = stepPromise(resultSignal, workQueue, root, result.promise);
        }

        if (result.status === 'done')
        {
            var promise = result.promise;
            var tag = promise.tag;
            root.result = tag === 'Succeed'
                ? Result.Ok(promise.value)
                : Result.Err(promise.value);
            updateWorkQueue(resultSignal, workQueue);
        }

        if (result.status === 'blocked')
        {
            root.promise = result.promise;
        }
    }

    function stepPromise(resultSignal, workQueue, root, promise)
    {
        var tag = promise.tag;

        if (tag === 'Succeed' || tag === 'Fail')
        {
            return mark('done', promise);
        }

        if (tag === 'Async')
        {
            var placeHolder = {};
            var couldBeSync = true;
            var wasSync = false;

            promise.asyncFunction(function(result) {
                placeHolder.tag = result.tag;
                placeHolder.value = result.value;
                if (couldBeSync)
                {
                    wasSync = true;
                }
                else
                {
                    startPromise(resultSignal, workQueue, root);
                }
            });
            couldBeSync = false;
            return mark(wasSync ? 'done' : 'blocked', placeHolder);
        }

        if (tag === 'AndThen' || tag === 'Catch')
        {
            var result = mark('runnable', promise.promise);
            while (result.status === 'runnable')
            {
                result = stepPromise(resultSignal, workQueue, root, result.promise);
            }

            if (result.status === 'done')
            {
                var activePromise = result.promise;
                var activeTag = activePromise.tag;

                var succeedChain = activeTag === 'Succeed' && tag === 'AndThen';
                var failChain = activeTag === 'Fail' && tag === 'Catch';

                return (succeedChain || failChain)
                    ? mark('runnable', promise.callback(activePromise.value));
                    : mark('runnable', activePromise);
            }
            if (result.status === 'blocked')
            {
                return mark('blocked', {
                    tag: tag,
                    promise: result.promise,
                    callback: promise.callback
                });
            }
        }
    }

    return localRuntime.Native.Promise.values = {
        succeed: succeed,
        fail: fail,
        asyncFunction: asyncFunction,
        andThen: F2(andThen),
        catch_: F2(catch_),
        run: F2(run)
    };
};
