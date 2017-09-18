#!/bin/sh

set -eu
set -o pipefail

cd proeject

./gradlew build

cd ..

cp project/build/libs/*.jar task-output/.
