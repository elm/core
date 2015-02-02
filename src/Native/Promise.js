Elm.Native.Promise = {};
Elm.Native.Promise.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Promise = localRuntime.Native.Promise || {};
    if (localRuntime.Native.Promise.values) {
        return localRuntime.Native.Promise.values;
    }

    var DEPTH_LIMIT = 0;

    function succeed(value) {
        return function(depth, callback) {
            return callback(depth + 1, 'Ok', value);
        }
    }

    function fail(error) {
        return function(depth, callback) {
            return callback(depth + 1, 'Err', error);
        }
    }

    function chain(desiredTag) {
        return function(promise, userCallback) {
            return function(depth, callback) {

                function newCallback(newDepth, tag, value) {
                    if (newDepth > DEPTH_LIMIT) {
                        return setTimeout(function() {
                            newCallback(0, tag, value);
                        }, 0);
                    }
                    if (tag === desiredTag) {
                        return userCallback(value)(newDepth + 1, callback);
                    }
                    return callback(newDepth + 1, tag, value);
                }

                return promise(depth + 1, newCallback);
            };
        };
    }

    var andThen = chain('Ok');
    var catch_ = chain('Err');

    return localRuntime.Native.Promise.values = {
        succeed: succeed,
        fail: fail,
        andThen: andThen,
        catch_: catch_
    };
};
