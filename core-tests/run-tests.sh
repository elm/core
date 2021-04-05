#!/usr/bin/env bash

set -o errexit;
set -o nounset;

# Let the caller supply an ELM_TEST binary if desired.
if [ -z "${ELM_TEST:-}" ]; then
    ELM_TEST=elm-test;
fi

# Since elm/core is treated specially by the compiler (it's always
# inserted as a dependency even when not declared explicitly), we use
# a bit of a hack to make the tests run against the local source code
# rather than the elm/core source fetched from package.elm-lang.org.

# Create a local directory where the compiler will look for the
# elm/core source code:

export ELM_HOME="$PWD/.elm";
rm -rf "$ELM_HOME" && mkdir -p "$ELM_HOME";
rm -rf elm-stuff;

# Create a link to the git package
CORE_LINK="${ELM_HOME}/0.19.1/packages/elm/core/1.0.5"
CORE_GIT_DIR="$(dirname $PWD)"
echo;
echo "Linking $CORE_LINK to $CORE_GIT_DIR"
echo;
mkdir -p "$(dirname $CORE_LINK)"
ln -sv "${CORE_GIT_DIR}" "${CORE_LINK}"
rm -vf "${CORE_GIT_DIR}"/*.dat "${CORE_GIT_DIR}"/doc*.json

# Now we can run the tests against the symlinked source code for real.
mkdir -p src/ # needed for compilation
echo;
echo "running tests ...";
echo;

"${ELM_TEST}" "$@";
