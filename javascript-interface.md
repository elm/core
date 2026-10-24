# JavaScript interface

When you compile Elm to JavaScript using `elm make MyModule.elm --output my-file.js`, how do you actually use that JavaScript file?

## Loading the file

### Browser

```html
<script src="my-file.js"></script>
```

(Note: The modern `type="module"` attribute or JavaScript `import` syntax won’t work. It has to be a plain script tag like above.)

The script creates a global variable called `Elm` where all the Elm things are:

```js
var app = Elm.MyModule.init();
```

If the `Elm` global variable already exists, it’s augmented. This allows you to load multiple Elm compiled JavaScript files on the same page.

### Node.js

`Platform.worker` programs can be used in [Node.js](https://nodejs.org/).

(The other program types can be used in Node.js, too, if you use the [jsdom](https://github.com/jsdom/jsdom) package.)

Node.js has two module systems: The old “CommonJS” system, and the newer “ESM” system.

For CommonJS:

```js
var { Elm } = require('./my-file.js');
var app = Elm.MyModule.init();
```

For ESM:

```js
import { createRequire } from 'node:module';
var require = createRequire(import.meta.url);
var { Elm } = require('./my-file.js');
var app = Elm.MyModule.init();
```

Alternative way:

```js
import fs from 'node:fs'; // or: var fs = require('fs');
var code = fs.readFileSync('./my-file.js', 'utf-8');
var f = new Function(code);
var scope = {};
f.call(scope);
var { Elm } = scope;
var app = Elm.MyModule.init();
```

## `Elm.MyModule.init()`

If your Elm module is called `MyModule`, you can initialize it like so:

```js
var app = Elm.MyModule.init({
	flags: myFlags,
	node: myDomNode
});
```

If the Elm module is `Blog.Home` it’s `Elm.Blog.Home.init()`, and so on.

`init` takes an object with up to two properties:

- `flags`: If your program takes flags (the first parameter of your Elm `init` function), this is where you pass them.
- `node`: Pass a DOM node to let Elm take over here, if your program requires one.

You can leave out properties that aren’t needed for your program, and the entire object if none of them are needed. Which ones can be used depend on the program type:

| Program               | `flags`  | `node`                   |
| --------------------- | -------- | ------------------------ |
| `Html`                | ignored  | required                 |
| `Browser.sandbox`     | ignored  | required                 |
| `Browser.element`     | optional | required                 |
| `Browser.document`    | optional | ignored, always `<body>` |
| `Browser.application` | optional | ignored, always `<body>` |
| `Platform.worker`     | optional | ignored, no `view`       |

The return value is an object with a few properties and functions described below. It’s typically called `app`.

## `app.ports`

If you define ports – _and use them_ – they’ll be available at `app.ports`.

For `myOutgoingPort : String -> Cmd msg`, use `app.ports.myOutgoingPort.subscribe(function(string) { console.log(string) })`. There’s also `unsubscribe` – put your listener function in a variable and pass it to `unsubscribe` to stop listening.

For `myIncomingPort : (String -> msg) -> Sub msg`, use `app.ports.myIncomingPort.send("hello")`.

If you don’t use any ports in your program, `app.ports` does not exist. (It’s _not_ an empty object!) If `app.ports` is unexpectedly missing, double check that your port actually ends up being used – all the way from where you call it, until its return value reaches `main`.

## `app.stop()`

This function stops your Elm app. This is useful for example when embedding your Elm app in a web component. When the web component unmounts, stop the Elm app.

`view`, `update` and `subscriptions` are stopped immediately, but pending `Cmd`s such as HTTP requests aren’t cancelled. When they finish, the messages they produce are silently ignored. At that point, if you no longer keep a reference to `app` it will be garbage collected.

You can pass an optional completion callback, which receives the final root DOM node for the app (or `null` for `Platform.worker`):

```js
app.stop(function(node) {
    if (node) {
        node.remove();
    }
});
```

The callback runs after the final draw and cleanup have finished.

Stopping also detaches the view (unless you already did that yourself), so read on about that function below for more details.

## `app.detachView()`

This is for advanced use cases. You probably want to use `app.stop()`.

`app.detachView(callback)` makes Elm release control over the DOM: It removes all event listeners and passes the final root DOM node to the completion callback (which is optional). This essentially turns the app into a `Platform.worker` – `update` and `subscriptions` will still run, and ports can be used. (If the app was a `Platform.worker` from the beginning, `app.detachView()` doesn’t do anything beyond calling the callback with `null`.)

As mentioned above for `app.stop()`, there might be pending `Cmd`s such as HTTP requests when you stop your Elm app. If it’s important for you to handle the messages they produce as they finish, use `app.detachView()` rather than `app.stop()`. `app.stop()` silently ignores the messages, while with `app.detachView()` they arrive to your `update` function as usual, and you can handle them somehow. Just remember that your `view` function won’t run anymore!

What `Cmd`s might be pending that you might want to care about?

- HTTP requests: You might have HTTP requests that aren’t finished yet. Note that you can use `Http.cancel` to cancel requests, and set a timeout on requests (using `Http.request`, `Http.riskyRequest` or `Http.task`) to avoid waiting forever. If the responses contain something important to show to the user, you could pass the outputs through a port.
- `Process.sleep`: You might be waiting for a certain amount of time to pass. If you do this in a loop, consider using `Time.every` instead.
- `File.Select.file` and `File.Select.files`: The user can have the browser file picker open. This is probably not very likely.
- `WebGL.Texture.load` and `WebGL.Texture.loadWith`: These download texture files. They don’t seem cancellable. Without a view, you probably don’t care about the texture anymore.

All other commands should finish almost instantly.

It isn’t possible to tell when the app is “done.” You can leave it running for a set time, or until some app-specific condition. With refactoring of Elm’s effect system, it might be possible to say that “no message-producing commands are pending,” but note that it’s still possible to send a value through a port at any time to make the app do work again. It’s also possible to have commands that produce messages, that trigger commands infinitely.

If your app needs to know that it is in this view-less state, use a port to tell it:

```js
app.detachView(function(node) {
    app.ports.onDetachedView.send(true);
});
```

## `app.stop()` and `app.detachView()` notes

| Program               | `app.stop()`         | `app.detachView()`    | callback argument |
| --------------------- | -------------------- | --------------------- | ----------------- |
| `Html`                | same as `detachView` |                       | root DOM node     |
| `Browser.sandbox`     | same as `detachView` |                       | root DOM node     |
| `Browser.element`     |                      |                       | root DOM node     |
| `Browser.document`    |                      |                       | `<body>`          |
| `Browser.application` |                      | also stops navigation | `<body>`          |
| `Platform.worker`     |                      | does nothing          | `null`            |

- `Html` and `Browser.sandbox` have no effects, so `app.stop()` does not have anything more to do than stopping the view. (Except one thing: The app won’t be garbage collected unless you call `app.stop()`. This is due to hot reloading, and does not apply for `--optimize`.)
- `Platform.worker` programs have no view, so `app.detachView()` doesn’t do anything, and the callbacks to both `app.stop()` and `app.detachView()` receive `null` as there is no DOM node.
- `Html`, `Browser.sandbox` and `Browser.element` programs all require a DOM node when initializing them: `Elm.MyModule.init({ node: myDomNode })`. Elm takes over `myDomNode` and uses it for rendering. Elm might even replace the DOM node with a new one, for example if you passed a `<div>` and then rendered a `<main>` element instead in your Elm view. The callback to `app.detachView()` receives the root DOM node after the final draw, which may or may not be the same one as the `myDomNode` you passed when initializing. Inside the callback, you can use that DOM node to for example remove it from the page, or pass it to a new Elm app.
- `Browser.document` and `Browser.application` always use the `<body>` element on the page for rendering. The callbacks to `app.stop()` and `app.detachView()` receive that `<body>` element. Unless you’ve done something very unconventional, it is the same as `document.body`.
- `Browser.application` programs react to the user using the back and forward buttons of the browser, by listening to the `popstate` event. This event listener is removed by `app.detachView()`.

Here’s a comparison with trying to stop an Elm app using Elm code vs using `app.stop()` and `app.detachView()`:

```elm
main =
    Browser.application
        -- `init` is run just once, so there’s nothing to stop.
        { init = init

        -- `subscriptions` can be stopped via a flag in the model.
        -- `app.stop()` does the equivalent of this, and makes sure `subscriptions` isn’t called again.
        , subscriptions =
            \model ->
                if model.stopped then
                    Sub.none

                else
                    subscriptions model

        -- `update` can be made to ignore messages via a flag in the model.
        -- `app.stop()` does the equivalent of this, except your `update` won’t even be called.
        , update =
            \msg model ->
                if model.stopped then
                    ( model, Cmd.none )

                else
                    update msg model

        -- `view` can’t be stopped, but it’s possible to render something empty.
        -- `app.stop()` or `app.detachView()` keeps the last rendered DOM, but removes
        -- event listeners from it, and makes sure `view` isn’t even called again.
        , view =
            \model ->
                if model.stopped then
                    Html.text ""

                else
                    view model

        -- Since `view` renders an empty text node, there are no links to click.
        -- `app.stop()` and `app.detachView()` remove the click listeners from all links rendered by Elm.
        , onUrlRequest = LinkClicked

        -- This can be triggered by all functions that take `Browser.Navigation.Key`, but since
        -- `update` always returns `Cmd.none` that won’t happen. If the user uses the browser
        -- back and forward buttons, though, it will trigger.
        -- `app.stop()` and `app.detachView()` remove the listener for the browser back and forward
        -- buttons, so it won’t trigger.
        , onUrlChange = UrlChanged
        }
```

## `Elm.hot.reload()`

This is intended for people who develop plugins for build tools.

The plugin could fetch new compiled JavaScript, and use it like so:

```js
var f = new Function(newCompiledElmCodeAsString);
var newScope = {};
f.call(newScope);
Elm.hot.reload(newScope);
```

The above updates all modules on `Elm` (such as `Elm.Main` and `Elm.Blog.Home`), so that calling `.init()` on one of them would initialize an Elm app using the latest code rather than the old.

It also updates all running Elm app instances, without losing any state. It does this by injecting updated versions of `view`, `update`, `subscriptions` etc. into them.

(Other properties of `Elm.hot` are private and not supposed to be used.)

If the build tool is ESM based and uses the common `import.meta.hot` API, here’s the basics of it:

```js
const scope = {};

(function () {
	// Put the compiled Elm JavaScript code here.
}).call(scope);

export const Elm = scope.Elm;

if (import.meta.hot) {
	import.meta.hot.data.Elm ??= Elm;

	import.meta.hot.accept((newModule) => {
		if (somehowTellIfMainProgramTypeChanged) {
			import.meta.hot.invalidate('Incompatible Elm type changes.');
		} else {
			import.meta.hot.data.Elm.hot.reload(newModule);
		}
	});
}
```

If the type of `main` has changed (including adding or removing custom type variants or record fields), the page should be reloaded rather than using `Elm.hot.reload()`. The latter could cause runtime errors, since the new functions aren’t compatible with the previous model, for example.
