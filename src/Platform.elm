module Platform
  ( Program
  , Process
  )
  where

{-|

# Programs
@docs Program

# Processes
@docs Process

-}



-- PROGRAMS


{-| Every Elm project will define `main` to be some sort of `Program`. A
`Program` value captures all the details needed to manage your application,
including how to initialize things, how to respond to events, etc.

The type of a `Program` includes a `flags` type variable which describes the
data we need to start a program. So say our program needs to be given a `userID`
and `token` to get started:

    MyApp.main : Program { userID : String, token : Int }

So when we initialize this program in JavaScript, we can give the necessary flags
really easily!

```javascript
Elm.MyApp.fullscreen({
    userID: "Tom",
    token: 42
});
```
-}
type Program flags = Program



-- PROCESSES


{-| Head over to the documentation for the [`Process`](Process) module for
information on how this works. It is only defined here because it needs to be
a platform primitive for both the `Task` and `Process` modules to use it.
-}
type Process exit msgs = Process

