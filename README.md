# Elm Core Libraries

Every Elm project needs the core libraries. They provide basic functionality including:

  * The Basics &mdash; addition, subtraction, etc.
  * Data Structures &mdash; lists, dictionaries, sets, etc.

If you want to learn more about Elm, check out the examples on [elm-lang.org](http://elm-lang.org/) or the getting started guide at [guide.elm-lang.org](https://guide.elm-lang.org/).


## Default Imports

All Elm files have some default imports:

```elm
import Basics exposing (..)
import List exposing ( List, (::) )
import Maybe exposing ( Maybe( Just, Nothing ) )
import Result exposing ( Result( Ok, Err ) )
import String
import Tuple

import Debug

import Platform exposing ( Program )
import Platform.Cmd as Cmd exposing ( Cmd )
import Platform.Sub as Sub exposing ( Sub )
```

The intention is to include things that are both extremely useful and very
unlikely to overlap with anything that anyone will ever write in a library.
By keeping the set of default imports small, it also becomes easier to use
whatever version of `map` suits your fancy. Finally, it makes it easier to
figure out where the heck a function is coming from.

## Running Tests Locally

After cloning down the repo, `cd` into `core` and run `bash tests/set-up-tests.sh`.
If successful, you will see a few messages: (1) That the packages have been
configured successfully; (2) That the modules were compiled; and (3) That
`raw-test.js` was successfully generated.

At this point you can run `node tests/test.js` to run the entire test suite.
One thing to note is that currently, you will need to run the `bash` script
again if you modify, delete or add tests to recompile everything.
