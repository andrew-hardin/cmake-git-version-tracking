cmake_minimum_required(VERSION 3.2)

# Pull in the code to watch git.
# This automatically defines the AlwaysCheckGit target.
include(git_watcher.cmake)

# Create a demo executable.
# Note that one of the dependencies is the configured git header.
add_executable(demo git.h main.cc)

# Indicate that the demo depends on the AlwaysCheckGit target.
# Whenever we try to build demo, we'll first check the repo for any changes.
# If any changes were made, then git.h will be updated.
# Then demo will be rebuilt with that updated header.
add_dependencies(demo AlwaysCheckGit)
