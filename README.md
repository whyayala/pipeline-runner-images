# pipeline-runner-images

A collection of images to use with a ci/cd pipeline.

For buildah to run in a locked down container, you must provide it the seccomp used by podman [found here.](https://raw.githubusercontent.com/containers/podman/refs/tags/v5.2.5/vendor/github.com/containers/common/pkg/seccomp/seccomp.json)