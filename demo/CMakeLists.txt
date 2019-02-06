cmake_minimum_required(VERSION 3.2)

# Define the two required variables before including
# the source code for watching a git repository.
set(PRE_CONFIGURE_FILE "git.h.in")
set(POST_CONFIGURE_FILE "git.h")
include(git_watcher.cmake)

# Create a demo executable.
# Note that one of the dependencies is the configured git header.
add_executable(demo ${POST_CONFIGURE_FILE} main.cc)
add_dependencies( demo check_git_repository )
