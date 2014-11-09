Elm.Native.JavaScript = {};
Elm.Native.JavaScript.make = function(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.JavaScript = localRuntime.Native.JavaScript || {};
    if (localRuntime.Native.JavaScript.values) {
        return localRuntime.Native.JavaScript.values;
    }

    var ElmArray = Elm.Native.Array.make(localRuntime);
    var List = Elm.Native.List.make(localRuntime);
    var Maybe = Elm.Maybe.make(localRuntime);
    var Result = Elm.Result.make(localRuntime);
    var Utils = Elm.Native.Utils.make(localRuntime);


    function crash(expected, actual) {
        throw new Error(
            'expecting ' + expected + ' but got ' + JSON.stringify(actual)
        );
    }


    // PRIMITIVE VALUES

    function decodeNull(value) {
        if (value === null) {
            return Utils.Tuple0;
        }
        crash('null', value);
    }


    function decodeString(value) {
        if (typeof value === 'string' || value instanceof String) {
            return value;
        }
        crash('a String', value);
    }


    function decodeFloat(value) {
        if (typeof value === 'number') {
            return value;
        }
        crash('a Float', value);
    }


    function decodeInt(value) {
        if (typeof value === 'number' && (value|0) === value) {
            return value;
        }
        crash('an Int', value);
    }


    function decodeBool(value) {
        if (typeof value === 'boolean') {
            return value;
        }
        crash('a Bool', value);
    }


    // ARRAY

    function decodeArray(decoder) {
        return function(value) {
            if (value instanceof Array) {
                var len = value.length;
                var array = new Array(len);
                for (var i = len; i-- ; ) {
                    array[i] = decoder(value[i]);
                }
                return ElmArray.fromJSArray(array);
            }
            crash('an Array', value);
        };
    }


    // LIST

    function decodeList(decoder) {
        return function(value) {
            if (value instanceof Array) {
                var len = value.length;
                var list = List.Nil;
                for (var i = len; i-- ; ) {
                    list = List.Cons( decoder(value[i]), list );
                }
                return list;
            }
            crash('a List', value);
        };
    }


    // MAYBE

    function decodeMaybe(decoder) {
        return function(value) {
            try {
                return Maybe.Just(decoder(value));
            } catch(e) {
                return Maybe.Nothing;
            }
        };
    }


    // FIELDS

    function decodeField(field, decoder) {
        return function(value) {
            var subValue = value[field];
            if (subValue !== undefined) {
                return decoder(subValue);
            }
            crash("an object with field '" + field + "'", value);
        };
    }


    // OBJECTS

    function decodeObject1(f, d1) {
        return function(value) {
            return f(d1(value));
        };
    }

    function decodeObject2(f, d1, d2) {
        return function(value) {
            return A2( f, d1(value), d2(value) );
        };
    }

    function decodeObject3(f, d1, d2, d3) {
        return function(value) {
            return A3( f, d1(value), d2(value), d3(value) );
        };
    }

    function decodeObject4(f, d1, d2, d3, d4) {
        return function(value) {
            return A4( f, d1(value), d2(value), d3(value), d4(value) );
        };
    }

    function decodeObject5(f, d1, d2, d3, d4, d5) {
        return function(value) {
            return A5( f, d1(value), d2(value), d3(value), d4(value), d5(value) );
        };
    }

    function decodeObject6(f, d1, d2, d3, d4, d5, d6) {
        return function(value) {
            return A6( f,
                d1(value),
                d2(value),
                d3(value),
                d4(value),
                d5(value),
                d6(value)
            );
        };
    }

    function decodeObject7(f, d1, d2, d3, d4, d5, d6, d7) {
        return function(value) {
            return A7( f,
                d1(value),
                d2(value),
                d3(value),
                d4(value),
                d5(value),
                d6(value),
                d7(value)
            );
        };
    }

    function decodeObject8(f, d1, d2, d3, d4, d5, d6, d7, d8) {
        return function(value) {
            return A8( f,
                d1(value),
                d2(value),
                d3(value),
                d4(value),
                d5(value),
                d6(value),
                d7(value),
                d8(value)
            );
        };
    }


    // TUPLES

    function decodeTuple1(f, d1) {
        return function(value) {
            if ( !(value instanceof Array) || value.length !== 1 ) {
                crash('a Tuple of length 1', value);
            }
            return f( d1(value[0]) );
        };
    }

    function decodeTuple2(f, d1, d2) {
        return function(value) {
            if ( !(value instanceof Array) || value.length !== 2 ) {
                crash('a Tuple of length 2', value);
            }
            return A2( f, d1(value[0]), d2(value[1]) );
        };
    }

    function decodeTuple3(f, d1, d2, d3) {
        return function(value) {
            if ( !(value instanceof Array) || value.length !== 3 ) {
                crash('a Tuple of length 3', value);
            }
            return A3( f, d1(value[0]), d2(value[1]), d3(value[2]) );
        };
    }


    function decodeTuple4(f, d1, d2, d3, d4) {
        return function(value) {
            if ( !(value instanceof Array) || value.length !== 4 ) {
                crash('a Tuple of length 4', value);
            }
            return A4( f, d1(value[0]), d2(value[1]), d3(value[2]), d4(value[3]) );
        };
    }


    function decodeTuple5(f, d1, d2, d3, d4, d5) {
        return function(value) {
            if ( !(value instanceof Array) || value.length !== 5 ) {
                crash('a Tuple of length 5', value);
            }
            return A5( f,
                d1(value[0]),
                d2(value[1]),
                d3(value[2]),
                d4(value[3]),
                d5(value[4])
            );
        };
    }


    function decodeTuple6(f, d1, d2, d3, d4, d5, d6) {
        return function(value) {
            if ( !(value instanceof Array) || value.length !== 6 ) {
                crash('a Tuple of length 6', value);
            }
            return A6( f,
                d1(value[0]),
                d2(value[1]),
                d3(value[2]),
                d4(value[3]),
                d5(value[4]),
                d6(value[5])
            );
        };
    }

    function decodeTuple7(f, d1, d2, d3, d4, d5, d6, d7) {
        return function(value) {
            if ( !(value instanceof Array) || value.length !== 7 ) {
                crash('a Tuple of length 7', value);
            }
            return A7( f,
                d1(value[0]),
                d2(value[1]),
                d3(value[2]),
                d4(value[3]),
                d5(value[4]),
                d6(value[5]),
                d7(value[6])
            );
        };
    }


    function decodeTuple8(f, d1, d2, d3, d4, d5, d6, d7, d8) {
        return function(value) {
            if ( !(value instanceof Array) || value.length !== 8 ) {
                crash('a Tuple of length 8', value);
            }
            return A8( f,
                d1(value[0]),
                d2(value[1]),
                d3(value[2]),
                d4(value[3]),
                d5(value[4]),
                d6(value[5]),
                d7(value[6]),
                d8(value[7])
            );
        };
    }


    // CUSTOM DECODERS

    function decodeValue(value) {
        return value;
    }

    function customGetter(get) {
        return function(value) {
            var result = get(value);
            if (result.ctor === 'Ok') {
                return result._0;
            } else {
                throw new Error('custom getter failed on ' + JSON.stringify(value));
            }
        }
    }


    // ONE OF MANY

    function oneOf(decoders) {
        return function(value) {
            var errors = [];
            while (decoders.ctor !== '[]') {
                try {
                    return decoders._0(value);
                } catch(e) {
                    errors.push(e.message);
                }
                decoders = decoders._1;
            }
            throw new Error('expecting one of the following:\n    ' + errors.join('\n    '));
        }
    }

    function get(decoder, value) {
        try {
            return Result.Ok(decoder(value));
        } catch(e) {
            return Result.Err(e.message);
        }
    }


    // ENCODE / DECODE

    function fromString(string) {
        try {
            return Result.Ok(JSON.parse(string));
        } catch(e) {
            return Result.Err(e.message);
        }
    }

    function toString(sep, value) {
        return JSON.stringify(value, sep);
    }


    return localRuntime.Native.JavaScript.values = {
        toString: toString,
        fromString: fromString,

        get: F2(get),
        oneOf: oneOf,

        decodeNull: decodeNull,
        decodeInt: decodeInt,
        decodeFloat: decodeFloat,
        decodeString: decodeString,
        decodeBool: decodeBool,

        decodeMaybe: decodeMaybe,

        decodeList: decodeList,
        decodeArray: decodeArray,

        decodeField: F2(decodeField),

        decodeObject1: F2(decodeObject1),
        decodeObject2: F3(decodeObject2),
        decodeObject3: F4(decodeObject3),
        decodeObject4: F5(decodeObject4),
        decodeObject5: F6(decodeObject5),
        decodeObject6: F7(decodeObject6),
        decodeObject7: F8(decodeObject7),
        decodeObject8: F9(decodeObject8),

        decodeTuple1: F2(decodeTuple1),
        decodeTuple2: F3(decodeTuple2),
        decodeTuple3: F4(decodeTuple3),
        decodeTuple4: F5(decodeTuple4),
        decodeTuple5: F6(decodeTuple5),
        decodeTuple6: F7(decodeTuple6),
        decodeTuple7: F8(decodeTuple7),
        decodeTuple8: F9(decodeTuple8),

        decodeValue: decodeValue,
        customGetter: customGetter

    };

};
