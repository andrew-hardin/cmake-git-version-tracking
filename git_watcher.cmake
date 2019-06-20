# git_watcher.cmake
#
# License: MIT
# Source: https://raw.githubusercontent.com/andrew-hardin/cmake-git-version-tracking/master/git_watcher.cmake


# This file defines the functions and targets needed to monitor
# the state of a git repo. If the state changes (e.g. a commit is made),
# then a file gets reconfigured.
#
# The behavior of this script can be modified by defining any of these variables:
#
#   PRE_CONFIGURE_FILE (REQUIRED)
#   -- The path to the file that'll be configured.
#
#   POST_CONFIGURE_FILE (REQUIRED)
#   -- The path to the configured PRE_CONFIGURE_FILE.
#
#   GIT_STATE_FILE (OPTIONAL)
#   -- The path to the file used to store the previous build's git state.
#      Defaults to the current binary directory.
#
#   GIT_WORKING_DIR (OPTIONAL)
#   -- The directory from which git commands will be run.
#      Defaults to the directory with the top level CMakeLists.txt.
#
#   GIT_EXECUTABLE (OPTIONAL)
#   -- The path to the git executable. It'll automatically be set if the
#      user doesn't supply a path.
#
#   VERSION_TAG_PREFIX_REGEX (OPTIONAL)
#   -- A regex that specifies the prefix that needs to be removed to get to the
#      version number (default is '^v' and will match tags like 'v1.0.34')
#
# Script design:
#   - This script was designed similar to a Python application
#     with a Main() function. I wanted to keep it compact to
#     simplify "copy + paste" usage.
#
#   - This script is made to operate in two CMake contexts:
#       1. Configure time context (when build files are created).
#       2. Build time context (called via CMake -P)
#     If you see something odd (e.g. the NOT DEFINED clauses),
#     consider that it can run in one of two contexts.

# Short hand for converting paths to absolute.
macro(PATH_TO_ABSOLUTE var_name)
    get_filename_component(${var_name} "${${var_name}}" ABSOLUTE)
endmacro()

# Check that a required variable is set.
macro(CHECK_REQUIRED_VARIABLE var_name)
    if(NOT DEFINED ${var_name})
        message(FATAL_ERROR "The \"${var_name}\" variable must be defined.")
    endif()
endmacro()

# Check that an optional variable is set, or, set it to a default value.
macro(CHECK_OPTIONAL_VARIABLE var_name default_value)
    if(NOT DEFINED ${var_name})
        set(${var_name} ${default_value})
    endif()
endmacro()

CHECK_REQUIRED_VARIABLE(PRE_CONFIGURE_FILE)
PATH_TO_ABSOLUTE(PRE_CONFIGURE_FILE)
CHECK_REQUIRED_VARIABLE(POST_CONFIGURE_FILE)
PATH_TO_ABSOLUTE(POST_CONFIGURE_FILE)
CHECK_OPTIONAL_VARIABLE(GIT_STATE_FILE "${CMAKE_BINARY_DIR}/git-state")
PATH_TO_ABSOLUTE(GIT_STATE_FILE)
CHECK_OPTIONAL_VARIABLE(GIT_WORKING_DIR "${CMAKE_SOURCE_DIR}")
PATH_TO_ABSOLUTE(GIT_WORKING_DIR)

CHECK_OPTIONAL_VARIABLE(VERSION_TAG_PREFIX_REGEX "^v")

set(GIT_DIRTY_MARK "dirty")
set(GIT_STATE_UNKNOWN "unknown")

# Check the optional git variable.
# If it's not set, we'll try to find it using the CMake packaging system.
if(NOT DEFINED GIT_EXECUTABLE)
    find_package(Git QUIET REQUIRED)
endif()
CHECK_REQUIRED_VARIABLE(GIT_EXECUTABLE)



# Function: GitStateChangedAction
# Description: this function is executed when the state of the git
#              repo changes (e.g. a commit is made).
function(GitStateChangedAction _state)

    # Define default values in case of missing values or an unknown state.
    set(GIT_RETRIEVED_STATE "false")
    set(GIT_IS_DIRTY "false")
    set(GIT_ADDITIONAL_COMMITS "-1")
    set(VERSION_MAJOR "-1")
    set(VERSION_MINOR "-1")
    set(VERSION_PATCH "-1")

    if(NOT _state STREQUAL "${GIT_STATE_UNKNOWN}")
        # Set variables by index, then configure the file w/ these variables defined.

        set(GIT_RETRIEVED_STATE "true")
        string(REPLACE "-" ";" state_items ${_state})

        # Find the dirty mark and remove it if it existed.
        list(GET state_items -1 dirty_mark_item)
        if(dirty_mark_item STREQUAL "${GIT_DIRTY_MARK}")
            set(GIT_IS_DIRTY "true")
            list(REMOVE_AT state_items -1)
        endif()

        # Find the sha1 hash and later remove the git prefix if needed.
        list(GET state_items -1 GIT_HEAD_SHA1)
        list(REMOVE_AT state_items -1)

        # Check if there are additional items, which means that a git tag was present.
        # Otherwise we only got the hash without 'g' prefix and dirty flag (see git discribe's --always option)
        list(LENGTH state_items state_items_length)
        if(NOT state_items_length EQUAL 0)
            # Only remove the prefix if a tag was present.
            string(SUBSTRING "${GIT_HEAD_SHA1}" 1 -1 GIT_HEAD_SHA1)

            # Find the number of additional commits - if this is 0 we are exactly at the given tag.
            list(GET state_items -1 GIT_ADDITIONAL_COMMITS)
            list(REMOVE_AT state_items -1)

            # The remaining items contain the git tag and need get re-joined.
            string(REPLACE ";" "-" GIT_TAG "${state_items}") # or use list(JOIN state_items "-" GIT_TAG) if you got cmake 3.12

            # Fetch the version number by parsing the git tag.
            string(REGEX REPLACE "${VERSION_TAG_PREFIX_REGEX}([0-9\\.]+)"
                "\\1" VERSION "${GIT_TAG}")

            if(CMAKE_MATCH_COUNT EQUAL 1)
                string(REGEX MATCHALL "[0-9]+" version_items "${VERSION}")
                list(LENGTH version_items version_items_length)
                if(version_items_length GREATER 0)
                    list(GET version_items 0 VERSION_MAJOR)
                    if(version_items_length GREATER 1)
                        list(GET version_items 1 VERSION_MINOR)
                        if(version_items_length GREATER 2)
                            list(GET version_items 2 VERSION_PATCH)
                        endif()
                    endif()
                endif()
            endif()
        endif()
    endif()

    configure_file("${PRE_CONFIGURE_FILE}" "${POST_CONFIGURE_FILE}" @ONLY)
endfunction()



# Function: GetGitState
# Description: gets the current state of the git repo.
# Args:
#   _working_dir (in)  string; the directory from which git commands will be executed.
#   _state       (out) string; the output of the git discribe call (i.a. commit SHA).
function(GetGitState _working_dir _state)
    # Get tag, hash and dirty values from git describe
    execute_process(COMMAND
        "${GIT_EXECUTABLE}" describe --tags --always --long --abbrev=40 --dirty=-${GIT_DIRTY_MARK}
        WORKING_DIRECTORY "${_working_dir}"
        RESULT_VARIABLE res
        OUTPUT_VARIABLE out
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT res EQUAL 0)
        set(out ${GIT_STATE_UNKNOWN})
    endif()

    # Return the result of git describe command to the parent scope.
    set(${_state} ${out} PARENT_SCOPE)
endfunction()



# Function: CheckGit
# Description: check if the git repo has changed. If so, update the state file.
# Args:
#   _working_dir    (in)  string; the directory from which git commands will be ran.
#   _state_changed (out)    bool; whether or no the state of the repo has changed.
#   _state         (out)    string; the repository state as a git describe string (e.g. commit SHA).
function(CheckGit _working_dir _state_changed _state)

    # Get the current state of the repo.
    GetGitState("${_working_dir}" state)

    # Set the output _state variable.
    # (Passing by reference in CMake is awkward...)
    set(${_state} ${state} PARENT_SCOPE)

    # Check if the state has changed compared to the backup on disk.
    if(EXISTS "${GIT_STATE_FILE}")
        file(READ "${GIT_STATE_FILE}" OLD_HEAD_CONTENTS)
        if(OLD_HEAD_CONTENTS STREQUAL "${state}")
            # State didn't change.
            set(${_state_changed} "false" PARENT_SCOPE)
            return()
        endif()
    endif()

    # The state has changed.
    # We need to update the state file on disk.
    # Future builds will compare their state to this file.
    file(WRITE "${GIT_STATE_FILE}" "${state}")
    set(${_state_changed} "true" PARENT_SCOPE)
endfunction()



# Function: SetupGitMonitoring
# Description: this function sets up custom commands that make the build system
#              check the state of git before every build. If the state has
#              changed, then a file is configured.
function(SetupGitMonitoring)
    add_custom_target(check_git_repository
        ALL
        DEPENDS ${PRE_CONFIGURE_FILE}
        BYPRODUCTS ${POST_CONFIGURE_FILE}
        COMMENT "Checking the git repository for changes..."
        COMMAND
            ${CMAKE_COMMAND}
            -D_BUILD_TIME_CHECK_GIT=TRUE
            -DGIT_WORKING_DIR=${GIT_WORKING_DIR}
            -DGIT_EXECUTABLE=${GIT_EXECUTABLE}
            -DGIT_STATE_FILE=${GIT_STATE_FILE}
            -DPRE_CONFIGURE_FILE=${PRE_CONFIGURE_FILE}
            -DPOST_CONFIGURE_FILE=${POST_CONFIGURE_FILE}
            -DPOST_CONFIGURE_FILE=${POST_CONFIGURE_FILE}
            -DVERSION_TAG_PREFIX_REGEX=${VERSION_TAG_PREFIX_REGEX}
            -P "${CMAKE_CURRENT_LIST_FILE}")
endfunction()



# Function: Main
# Description: primary entry-point to the script. Functions are selected based
#              on whether it's configure or build time.
function(Main)
    if(_BUILD_TIME_CHECK_GIT)
        # Check if the repo has changed.
        # If so, run the change action.
        CheckGit("${GIT_WORKING_DIR}" did_change state)
        if(did_change)
            GitStateChangedAction("${state}")
        endif()
    else()
        # >> Executes at configure time.
        SetupGitMonitoring()
    endif()
endfunction()

# And off we go...
Main()
