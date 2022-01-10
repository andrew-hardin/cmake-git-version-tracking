cmake_minimum_required(VERSION 3.2)
project(CMakeGitVersion)

# Define the two required variables before including
# the source code for watching a git repository.
set(PRE_CONFIGURE_FILE "git.cc.in")
set(POST_CONFIGURE_FILE "${CMAKE_CURRENT_BINARY_DIR}/git.cc")
include(git_watcher.cmake)

# Create a library out of the compiled post-configure file.
add_library(${PROJECT_NAME} STATIC ${POST_CONFIGURE_FILE})
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_dependencies(${PROJECT_NAME} check_git)


