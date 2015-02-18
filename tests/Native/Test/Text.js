Elm.Native.Test      = Elm.Native.Test || {};
Elm.Native.Test.Text = {};
Elm.Native.Test.Text.make = function(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Test = localRuntime.Native.Test || {};
    localRuntime.Native.Test.Text = localRuntime.Native.Test.Text || {};

    if (localRuntime.Native.Test.Text.values) {
        return localRuntime.Native.Test.Text.values;
    }

    var Utils = Elm.Native.Utils.make(localRuntime);

    function textToHtmlString(text) {
        // makeText returns a String object
        // use toString() to convert to a string primitive
        // which can be interpreted as an Elm String
        return Utils.makeText(text).toString();
    }

    return localRuntime.Native.Test.Text.values = {
        textToHtmlString: textToHtmlString
    };
};
