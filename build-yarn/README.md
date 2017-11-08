# build-yarn

This task is opinionated on how your `package.json` should be structured.

Only three scripts are called:
```
yarn install
yarn test
yarn bundle -p --output-path=../js-assets/
```

These scripts are treated as the interface into all webapp projects passed through the pipeline. This allows developers to include implementation details specific to each project, while the pipeline can remain general enough to serve multiple projects.

Therefore, it's recommended you structure `test` with things such as linting, and `bundle` with whatever you feel is necessary to build your project.

For example, notice how `test` calls other scripts which are included in the `package.json`:
```json
"scripts": {
  "test": "jest --config ./jest/jest.config.json && yarn run lint && yarn run stylelint",
  "updateSnapshots": "jest -u --config ./jest/jest.config.json",
  "lint": "eslint src/main/resources/assets/**/*.js",
  "stylelint": "stylelint src/main/resources/assets/**/*.less",
  "bundle": "rimraf ./target/classes/static && webpack --bail",
  "bundle-dev": "yarn run bundle --devtool source-map",
  "watch": "nodemon --exec yarn run bundle-dev --watch src/main/resources/assets -L"
},
```

## Overriding VM

The default image in `task.yml` is the latest from [Dockerhub](https://hub.docker.com/r/mhart/alpine-node/).
```yaml
image_resource:
  type: docker-image
  source:
    repository: mhart/alpine-node
    tag: 'latest'
```

If you need to override this image in your pipeline with a specific version, simply supply the `build-yarn` task with an `image: ` resource. For example:

```yaml
# Define a VM resource.
# This can be anything, including one you create yourself from a Dockerfile.
# As long as the VM you supply can run the shell environment defined in `task.sh` 
# (which is `#!/bin/ash`), it should work.
resources:
- name: vm-override
  type: docker-image
  source:
    repository: mhart/alpine-node
    tag: '8.9.1'

...

jobs:
- name: build
  plan:
  - aggregate:
    - get: vm-override # Make the VM available as a Job resource
    - get: pipeline-tasks
    - get: project
      resource: source-repo
      trigger: true
    - get: version
      params: {pre: rc}
  - task: build-yarn
    image: vm-override # Override the task with the VM
```