[![Build Status](https://travis-ci.com/andrew-hardin/cmake-git-version-tracking.svg?branch=master)](https://travis-ci.com/andrew-hardin/cmake-git-version-tracking)
# Embed Git metadata in C/C++ project
This is a demo project that shows how to embed up-to-date
git metadata in a C/C++ project via CMake. The entire
capability is baked into single self-contained
[script](git_watcher.cmake).

## "The proof of the pudding is in the eating!"
In other words, please clone the repository and [try out the demo](hello-world/README.md).

## A "why does this matter" use case
We're continuously shipping prebuilt binaries for an
application. A user discovers a bug and files a bug report.
By embedding up-to-date versioning information, the user
can include this in their report, e.g.:

```
Commit SHA1: 46a396e (46a396e6c1eb3d)
Dirty: false (there were no uncommitted changes at time of build)
```

This allows us to investigate the _precise_ version of the
application that the bug was reported in.

## Wait, doesn't this already exist?
Well, it depends on your specific requirements. Before writing this, I
searched far and wide for existing solutions. Each solution I found fell
into one of two categories:

- Write the commit ID to the header at configure time (e.g. `cmake <source_dir>`).
  This works well for automated build processes (e.g. check-in code and build artifacts).
  However, it has one weakness: any changes made after running `cmake`
  (e.g. `git commit -am "Changed X"`) aren't reflected in the header.

- Every time a build is started (e.g. `make`), write the commit ID to a header.
  While this was better than the above, it had one major drawback:
  any object file that includes the new header will be recompiled -- _even if the state
  of the git repo hasn't changed_.

## So what's the ideal solution?
We check Git every time a build is started (e.g. `make`) to see if anything has changed,
like a new commit to the current branch. If nothing has changed, then we don't
touch anything- _no recompiling or linking is triggered_. If something has changed, then we
reconfigure the header and CMake rebuilds any downstream dependencies.

## Tip: how to avoid unnecessary recompilations
If you're worried about lengthy recompilations, then **don't** place the
versioning information in a header that is then included in _every_ source
file. Doing so would defeat the purpose of partial rebuilds.

The [better example](better-example/README.md) demonstrates one approach
for solving the partial recompilation problem by moving the git metadata
from a header into a source file.
