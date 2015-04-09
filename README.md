# Elm Core Libraries

[![Build Status](https://travis-ci.org/elm-lang/core.png)](https://travis-ci.org/elm-lang/core)

Every Elm project needs the core libraries. They provide basic functionality including:

  * Basic operations like addition and subtraction
  * Core data structures like lists, dictionaries, and sets
  * Underlying implementation of Signals
  * Core rendering libraries

## Default Imports

In all Elm files there is a small set of default imports:

```haskell
import Basics exposing (..)
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
