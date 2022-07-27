cmake_minimum_required(VERSION 3.2)
project(hello-world)

set(VERSION_TRACKING_MODULE_PATH "" CACHE STRING "The location of the cmake-git-version-tracking repository")

include(FetchContent)
set(FETCHCONTENT_QUIET OFF)
FetchContent_Declare(cmake_git_version_tracking                   
    URL ${VERSION_TRACKING_MODULE_PATH}
)
FetchContent_MakeAvailable(cmake_git_version_tracking)

# Setup a demo executable that links to the git library.
add_executable(demo main.cc)
target_link_libraries(demo cmake_git_version_tracking)
