#!/bin/ash
#
# All UPERCASE variables are provided externally from this script

set -eu
set -o pipefail
[ 'true' = "${DEBUG:-}" ] && set -x

cd project

yarn install --silent
yarn run test --runInBand
yarn run stylelint
yarn run lint
yarn run bundle -p --output-path=../js-assets/