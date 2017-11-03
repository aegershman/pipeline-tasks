#!/bin/bash

# http://tldp.org/LDP/abs/html/options.html
set -o errexit
set -o nounset
set -o pipefail
[ 'true' = "${DEBUG:-}" ] && set -o xtrace

configure_git() {
  git config --global user.email "$CONFIG_EMAIL"
  git config --global user.name "$CONFIG_NAME"

  # repository=$(basename $(git ls-remote --get-url origin) .git)

  git remote rm origin
  git remote add origin "$URL_PROTOCOL://$OWNER:$ACCESS_TOKEN@$URL_HOST/$OWNER/$REPOSITORY.git"

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
  git commit --allow-empty -m "$AUTO_COMMIT_MSG"
  git push origin "$TARGET_BRANCH"
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