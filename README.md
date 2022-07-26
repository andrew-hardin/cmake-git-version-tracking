[![Regression Tests](https://github.com/andrew-hardin/cmake-git-version-tracking/actions/workflows/main.yml/badge.svg)](https://github.com/andrew-hardin/cmake-git-version-tracking/actions/workflows/main.yml)
# Embed Git metadata in C/C++ projects via CMake
This project embeds up-to-date git metadata in a standalone C/C++ static library via CMake.
It's written responsibly to only trigger rebuilds if git metadata changes (e.g. a new commit is added).
The core capability is baked into single self-contained
[script](git_watcher.cmake).

## Requirements
- CMake >= 3.2
- C Compiler (with C99 standard support)
- Git

## Quickstart via FetchContent
You can use CMake's `FetchContent` module to build the static library `cmake_git_version_tracking`:
```
FetchContent_Declare(cmake_git_version_tracking                   
  GIT_REPOSITORY https://github.com/andrew-hardin/cmake-git-version-tracking.git
  GIT_TAG TODO
)
FetchContent_MakeAvailable(cmake_git_version_tracking)

target_link_libraries(your_target
  cmake_git_version_tracking
)
```
Then [`#include git.h`](./git.h) and use the provided functions to retrieve git metadata.

## Intended use case
You're continuously shipping prebuilt binaries for an
application. A user discovers a bug and files a bug report.
By embedding up-to-date versioning information, the user
can include this in their report, e.g.:

```
Commit SHA1: 46a396e (46a396e6c1eb3d)
Dirty: false (there were no uncommitted changes at time of build)
```

This allows you to investigate the _precise_ version of the
application that the bug was reported in.

## Q: doesn't this already exist?
**A:** it depends on your specific requirements. Before writing this, I
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

## Q: what's the ideal efficient solution?
**A:** We check Git every time a build is started (e.g. `make`) to see if anything has changed,
like a new commit to the current branch. If nothing has changed, then we don't
touch anything- _no recompiling or linking is triggered_. If something has changed, then we
reconfigure the header and CMake rebuilds any downstream dependencies.
