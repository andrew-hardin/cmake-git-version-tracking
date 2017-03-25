# Embedding Git Versioning into a C/C++ Application
This is a demo project that shows how to embed up-to-date
versioning information into a C/C++ application via CMake.

## A "why does this matter" use case
We're continuously shipping prebuild binaries for an
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
  This was a poor solution- any changes (e.g. `git commit -am "Changed X"`) 
  aren't reflected in the header.

- Every time a build is started (e.g. `make`), write the commit ID to a header.
  While this was better than the above, it had one major drawback:
  any object file that includes the new header will be recompiled -- _even if the state
  of the git repo hasn't changed_.

## So what's the ideal solution?
We check Git every time a build is started (e.g. `make`) to see if anything has changed,
like a new commit to the current branch. If nothing has changed, then we don't
touch anything- _no recompiling or linking is triggered_. If something has changed, then we
reconfigure the header and CMake rebuilds any downstream dependencies.

## How to exercise the demo
1. Clone the repo.
2. Configure the project (`mkdir build && cd build && cmake ..`).
3. Build it (`make`).
3. Run `./demo`- note the SHA1.
4. Build it again- note that nothing is recompiled (sweet!).
5. Edit README.md, then build and run the demo- note that the demo now reports that the HEAD is dirty.
6. Commit something, then build and run the demo- note that the SHA1 has changed.

## Tip: how to avoid unnecessary recompilations
If you're worred about lengthy recompilations, then **don't** place the
versioning information in a header that is then included in _every_ source
file. Doing so would defeat the purpose of partial rebuilds.
I shudder to think of how much time would be wasted.

As an alternative, place the versioning information in a source file:

```
// In git.h
extern const std::string kGitSHA7;

// In git.cc.in
const std::string kGitSHA = "@GIT_SHA1@";

// CMake then takes git.cc.in and creates git.cc
const std::string kGitSHA = "1234567";
```

Thus, only `git.cc` need to be recompiled whenever a commit is made.
