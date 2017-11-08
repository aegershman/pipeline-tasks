#!/bin/bash

# http://tldp.org/LDP/abs/html/options.html
set -o errexit
set -o nounset
set -o pipefail
[ 'true' = "${DEBUG:-}" ] && set -o xtrace

include_readme() {
touch README.md
cat > README.md << '_EOF'
  # Semver Branch
  This branch was auto-generated on Concourse with a task using the following commands:
  ```
  git checkout --orphan "$TARGET_BRANCH"
  git rm --cached -rf .
  rm -rf -- *
  rm -f .gitignore .gitmodules
  git commit --allow-empty -m "auto-generated root commit"
  git push origin "$TARGET_BRANCH" --quiet &> /dev/null
  ```
  This will not create the semver _file_.
  The semver [_resource_](https://github.com/concourse/semver-resource#source-configuration) will create the file using `inital_version:`
_EOF

git add README.md
}


configure_git() {
  git config --global user.email "concourse@bot.biz"
  git config --global user.name "Concourse Bot"

  url=$(git ls-remote --get-url origin)
  if [[ $url =~ .*@.* ]]; then
    echo "Parsing an SSH remote url..."
    url=${url//://} # git@github.com:Org/repo => git@github.com/Org/repo
    url="${url/*@/https://$ACCESS_TOKEN@}" # => https://TOKEN@github.com/Org/repo
  elif [[ $url =~ .*https://.* ]]; then
    echo "Parsing an HTTPS remote url..."
    url="${url/https:\/\//https://$ACCESS_TOKEN@}" # https://github.com... => https://TOKEN@github.com...
  else
    echo "Unable to determine git remote protocol. Must be either ssh or https."
    exit 1
  fi

  git remote rm origin
  git remote add origin "$url"
  git fetch --all
}


create_new_semver_branch() {
  git checkout --orphan "$TARGET_BRANCH"
  git rm --cached -rf .
  rm -rf -- *
  rm -f .gitignore .gitmodules
  [ 'true' = "$INCLUDE_README" ] && include_readme
  git commit --allow-empty -m "auto-generated root commit"
  git push origin "$TARGET_BRANCH" --quiet &> /dev/null
}

cd project

configure_git

if git show-ref --quiet --verify -- "refs/remotes/origin/$TARGET_BRANCH"; then
  echo "Branch $TARGET_BRANCH already exists. Exiting."
  exit 0;
fi

echo "Creating branch $TARGET_BRANCH..."
create_new_semver_branch
