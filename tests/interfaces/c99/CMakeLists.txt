cmake_minimum_required(VERSION 3.11)
project(TestCInterface
    LANGUAGES C)
set(VERSION_TRACKING_MODULE_PATH "" CACHE STRING "The location of the cmake-git-version-tracking repository")

include(FetchContent)
FetchContent_Declare(cmake_git_version_tracking                   
    URL ${VERSION_TRACKING_MODULE_PATH}
)
FetchContent_MakeAvailable(cmake_git_version_tracking)

add_executable(demo main.c)
set_property(TARGET demo PROPERTY C_STANDARD 99)
target_link_libraries(demo cmake_git_version_tracking)
