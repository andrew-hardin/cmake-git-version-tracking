cmake_minimum_required(VERSION 3.2)

# Define the two required variables before including
# the source code for watching a git repository.
set(PRE_CONFIGURE_FILE "git.h.in")
set(POST_CONFIGURE_FILE "git.h")
include(git_watcher.cmake)

# Create a demo executable using a single source file that
# prints the information baked into the "git.h" header.
add_executable(demo main.cc)

# This last instruction is critical because it ensures
# we check git for changes prior to building the demo target.
add_dependencies(demo check_git)