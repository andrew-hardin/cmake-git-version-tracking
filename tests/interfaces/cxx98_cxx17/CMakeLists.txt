cmake_minimum_required(VERSION 3.11)
project(TestCXXInterface
    LANGUAGES C CXX)
set(CXX_STANDARD 98 CACHE STRING "Which CXX standard to compile against.")
set(VERSION_TRACKING_MODULE_PATH "" CACHE STRING "The location of the cmake-git-version-tracking repository")

include(FetchContent)
FetchContent_Declare(cmake_git_version_tracking                   
    URL ${VERSION_TRACKING_MODULE_PATH}
)
FetchContent_MakeAvailable(cmake_git_version_tracking)

add_executable(demo main.cc)
set_property(TARGET demo PROPERTY CXX_STANDARD ${CXX_STANDARD})
target_link_libraries(demo cmake_git_version_tracking)
