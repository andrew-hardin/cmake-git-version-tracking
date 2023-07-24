cmake_minimum_required(VERSION 3.2...3.27)
project(cmake_git_version_tracking
    LANGUAGES C)

# Define the two required variables before including
# the source code for watching a git repository.
set(PRE_CONFIGURE_FILE "git.c.in")
set(POST_CONFIGURE_FILE "${CMAKE_CURRENT_BINARY_DIR}/git.c")
include(git_watcher.cmake)

# Create a library out of the compiled post-configure file.
#
# Note that the include is a system include. This was done
# so downstream projects don't suffer from warnings on a
# 3rdparty library.
add_library(${PROJECT_NAME} STATIC ${POST_CONFIGURE_FILE})
target_include_directories(${PROJECT_NAME} SYSTEM PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_dependencies(${PROJECT_NAME} check_git)

# The C99 standard is only required because we're using <stdbool.h>.
# This could be removed if it's a problem for users, but would require the
# cmake configure() commands to translate true/false literals to 1/0.
set_property(TARGET ${PROJECT_NAME} PROPERTY C_STANDARD 99)
