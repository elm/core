Elm.Native = Elm.Native || {};
Elm.Native.Mouse = {};
Elm.Native.Mouse.make = function(localRuntime) {

    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Mouse = localRuntime.Native.Mouse || {};
    if (localRuntime.Native.Mouse.values) {
        return localRuntime.Native.Mouse.values;
    }

    var Signal = Elm.Signal.make(localRuntime);
    var Utils = Elm.Native.Utils.make(localRuntime);

    var position = Signal.constant(Utils.Tuple2(0,0));
    position.defaultNumberOfKids = 2;

    // do not move x and y into Elm. By setting their default number
    // of kids, it is possible to detatch the mouse listeners if
    // they are not needed.
    function fst(pair) {
        return pair._0;
    }
    function snd(pair) {
        return pair._1;
    }

    var x = A2( Signal.map, fst, position );
    x.defaultNumberOfKids = 0;

    var y = A2( Signal.map, snd, position );
    y.defaultNumberOfKids = 0;

    var isDown = Signal.constant(false);
    var clicks = Signal.constant(Utils.Tuple0);

    var node = localRuntime.isFullscreen()
        ? document
        : localRuntime.node;

    localRuntime.addListener([clicks.id], node, 'click', function click() {
        localRuntime.notify(clicks.id, Utils.Tuple0);
    });
    localRuntime.addListener([isDown.id], node, 'mousedown', function down() {
        localRuntime.notify(isDown.id, true);
    });
    localRuntime.addListener([isDown.id], node, 'mouseup', function up() {
        localRuntime.notify(isDown.id, false);
    });
    localRuntime.addListener([position.id], node, 'mousemove', function move(e) {
        localRuntime.notify(position.id, Utils.getXY(e));
    });

    return localRuntime.Native.Mouse.values = {
        position: position,
        x: x,
        y: y,
        isDown: isDown,
        clicks: clicks
    };
};
