#!/bin/bash

# http://tldp.org/LDP/abs/html/options.html
set -o errexit
set -o nounset
set -o pipefail
[ 'true' = "${DEBUG:-}" ] && set -o xtrace

configure_git() {
  git config --global user.email "concourse@bot.biz"
  git config --global user.name "Concourse Bot"

  # Modify the remote URL to contain the access token
  url=$(git ls-remote --get-url origin)
  if [[ $url =~ .*@.* ]]; then
    echo "Parsing an SSH remote url..."
    url=${url//://} # git@github.com:Org/repo => git@github.com/Org/repo
    url="${url/*@/https://$ACCESS_TOKEN@}" # => https://TOKEN@github.com/Org/repo
  elif [[ $httpsExample =~ .*https://.* ]]; then
    echo "Parsing an HTTPS remote url..."
    url="${url/https:\/\//https://$ACCESS_TOKEN@}" # https://github.com... => https://TOKEN@github.com...
  else
    echo "Unable to determine git remote protocol. Must be either ssh or https."
    exit 1
  fi

  git remote rm origin
  git remote add origin "$url"

  # Without this Concourse would push a branch to remote the first time,
  # then the next time the task ran, it would use the cached 
  # git resource which doesn't have a reference to the target branch.
  git fetch --all
}

# We won't create the version file; that'll be responsibility of semver resource.
# Sole purpose is to create the semver branch if it doesn't exist.
create_new_semver_branch() {
  git checkout --orphan "$TARGET_BRANCH"
  git rm --cached -rf .
  rm -rf -- *
  rm -f .gitignore .gitmodules
  git commit --allow-empty -m "auto-generated root commit"
  
  # Silence the push or else it'll broadcast the access token.
  # Use both --quiet and redirect to null. Just to be safe.
  git push origin "$TARGET_BRANCH" --quiet &> /dev/null
}

cd project

configure_git

if git show-ref --quiet --verify -- "refs/remotes/origin/$TARGET_BRANCH"; then
  echo "Branch $TARGET_BRANCH already exists. Exiting."
else
  echo "Creating branch $TARGET_BRANCH..."
  create_new_semver_branch
fi

exit 0