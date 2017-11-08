# What?
This task automatically creates the `version` branch in a repository if it doesn't already exist.

If the `version` branch _does_ exist, the task exits successfully.

There are two possibilities:
## 1. version branch doesn't exist, so it's created:
![branch created](./example_doc/images/branch-created.png "branch created")

## 2. version branch already exists, so do nothing:
![branch exists](./example_doc/images/branch-exists.png "branch exists")

# Why?
If you're onboarding old projects into concourse, you probably don't have a `version` branch.

As it stands, the `semver` resource doesn't automatically create the `version` branch. It only creates an initial `version` file.

# How?
Check out the `example_doc` folder.

* You'll find a `Vagrantfile` which will spool up a local concourse server.
* You'll find a `credentials.yml` file, which you'll need to fill out your git ssh key & a github oauth access token with `repo:` access.
* You'll find a `pipeline.yml`, which contains a few examples. All you need to do is point the `project` resource at a github project.
* You'll find a `Makefile`, which will deploy a little example pipeline to the local server. Just run `make test`.

# Access token?
It's really easy. [Check out the GitHub doc on OAuth access tokens here.](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)