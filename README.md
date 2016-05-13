# Elm Core Libraries

[![Build Status](https://travis-ci.org/elm-lang/core.svg?branch=master)](https://travis-ci.org/elm-lang/core)

Every Elm project needs the core libraries. They provide basic functionality including:

  * The Basics &mdash; addition, subtraction, etc.
  * Data Structures &mdash; lists, dictionaries, sets, etc.


## Default Imports

In all Elm files there is a small set of default imports:

```elm
import Basics exposing (..)
import Debug
import List exposing ( List, (::) )
import Maybe exposing ( Maybe( Just, Nothing ) )
import Result exposing ( Result( Ok, Err ) )
import Platform exposing ( Program )
import Platform.Cmd exposing ( Cmd, (!) )
import Platform.Sub exposing ( Sub )
```

The intention is to include things that are both extremely useful and very
unlikely to overlap with anything that anyone will ever write in a library.
By keeping the set of default imports small, it also becomes easier to use
whatever version of `map` suits your fancy. Finally, it makes it easier to
figure out where the heck a function is coming from.
