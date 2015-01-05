#!/bin/sh

cd "$(dirname "$0")"
set -e

elm-make --yes --output test.js Test.elm
cat elm-io-ports.js >> test.js
node test.js