#!/usr/bin/env bash

set -o errexit;
set -o nounset;

#let the caller supply an ELM_TEST binary if desired
if [ -z "${ELM_TEST:-}" ]; then
    ELM_TEST=elm-test;
fi

# since elm/core is treated specially by the compiler (it's always
# inserted as a dependency even when not declared explicitly), we use
# a bit of a hack to make the tests run against the local source code
# rather than the elm/core source fetched from package.elm-lang.org.

# create a local directory where the compiler will look for the
# elm/core source code:

DIR="$(dirname $0)";

cd "$DIR";

export ELM_HOME="$(pwd)/.elm";

rm -rf "$ELM_HOME" && mkdir -p "$ELM_HOME";

# elm-test also puts some things in elm-stuff, start with a clean
# slate there as well

rm -rf elm-stuff;

# now make an initial run of the tests to populate .elm and elm-stuff;
# this will test against elm/core from package.elm-lang.org, so we
# don't really care what the results are; we just need to force all
# the *other* dependencies to be fetched and set up.

echo "seeding framework for test dependencies ...";

# '|| true' lets us ignore failures here and keep the script running.
# useful when developing a fix for a bug that exists in the version of
# elm/core hosted on package.elm-lang.org
"${ELM_TEST}" tests/Main.elm --fuzz=1 > /dev/null || true;

# clear out the copy of elm-core fetched by the above and replace it
# with the local source code we want to actually test

VERSION_DIR="$(ls ${ELM_HOME}/0.19.1/packages/elm/core/)"
CORE_PACKAGE_DIR="${ELM_HOME}/0.19.1/packages/elm/core/$VERSION_DIR"
CORE_GIT_DIR="$(dirname $PWD)"

echo;
echo "Linking $CORE_PACKAGE_DIR to $CORE_GIT_DIR"
echo;

rm -rf "$CORE_PACKAGE_DIR"
ln -sv "$CORE_GIT_DIR" "$CORE_PACKAGE_DIR"
rm -vf "${CORE_GIT_DIR}"/*.dat "${CORE_GIT_DIR}"/doc*.json

# we also need to clear out elm-test's elm-stuff dir, since otherwise
# the compiler complains that its .dat files are out of sync

rm -rf elm-stuff;

# now we can run the tests against the symlinked source code for real

echo;
echo "running tests ...";
echo;

"${ELM_TEST}" tests/Main.elm "$@";
