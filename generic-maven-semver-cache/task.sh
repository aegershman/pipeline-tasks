#!/bin/ash
# This script assumes Maven Wrapper is used with Maven v3.5.0 or higher.
#   see: https://maven.apache.org/maven-ci-friendly.html
#
# All UPERCASE variables are provided externally from this script

set -eu
set -o pipefail
[ 'true' = "${DEBUG:-}" ] && set -x

version=$(cat version/version)

cd project

args="-Drevision=$version"
[ -n "$MAVEN_PROJECTS" ] && args="$args --projects $MAVEN_PROJECTS"
[ -n "$MAVEN_REPO_MIRROR" ] && args="$args -Drepository.url=$MAVEN_REPO_MIRROR";
[ -n "$MAVEN_REPO_USERNAME" ] && args="$args -Drepository.username=$MAVEN_REPO_USERNAME";
[ -n "$MAVEN_REPO_PASSWORD" ] && args="$args -Drepository.password=$MAVEN_REPO_PASSWORD";
[ "true" = "$MAVEN_REPO_CACHE_ENABLE" ] && args="$args -Dmaven.repo.local=$PWD/.m2repository"

./mvnw $CMD $args

if [ -d target ]; then
  cp -a target/* ../task-output/.
elif [ -f *pom.xml ]; then
  output=$(printf 'LOCAL_REPOSITORY=${settings.localRepository}\nGROUP_ID=${project.groupId}\nARTIFACT_ID=${project.artifactId}\nPOM_VERSION=${project.version}\n0\n' | ./mvnw help:evaluate $args)
  artifactId=$(echo "$output" | grep '^ARTIFACT_ID' | cut -d = -f 2)
  cp -a *pom.xml ../task-output/${artifactId}-pom.xml
else
  echo "No target folder could be found. Exiting gracefully."
fi
