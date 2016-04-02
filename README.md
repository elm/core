# Elm Core Libraries

[![Build Status](https://travis-ci.org/elm-lang/core.svg?branch=master)](https://travis-ci.org/elm-lang/core)

Every Elm project needs the core libraries. They provide basic functionality including:

  * The Basics &mdash; addition, subtraction, etc.
  * Data Structures &mdash; lists, dictionaries, sets, etc.
  * Signals &mdash; to make Elm programs reactive


## Default Imports

In all Elm files there is a small set of default imports:

```elm
import Basics exposing (..)
import Debug
import List exposing ( List, (::) )
import Maybe exposing ( Maybe( Just, Nothing ) )
import Result exposing ( Result( Ok, Err ) )
import Signal exposing ( Signal )
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
