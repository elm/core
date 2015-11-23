#!/bin/sh

cd "$(dirname "$0")"
set -e

elm-package install -y

VERSION_DIR="$(ls elm-stuff/packages/elm-lang/core/)"
CORE_PACKAGE_DIR="elm-stuff/packages/elm-lang/core/$VERSION_DIR"
CORE_GIT_DIR="$(dirname $PWD)"

ELM_CONSOLE_VERSION_DIR="$(ls elm-stuff/packages/laszlopandy/elm-console/)"
ELM_CONSOLE_IO_SRIPT="elm-stuff/packages/laszlopandy/elm-console/$ELM_CONSOLE_VERSION_DIR/elm-io.sh"

echo "Linking $CORE_PACKAGE_DIR to $CORE_GIT_DIR"
rm -rf $CORE_PACKAGE_DIR
ln -s $CORE_GIT_DIR $CORE_PACKAGE_DIR

echo "Compiling Test.elm to raw-test.js"
elm-make --yes --output raw-test.js Test.elm

echo "Patching raw-test.js to test.js"
chmod +x $ELM_CONSOLE_IO_SRIPT
./$ELM_CONSOLE_IO_SRIPT raw-test.js test.js

echo "Running test.js"
node test.js