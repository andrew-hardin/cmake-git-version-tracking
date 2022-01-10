cmake_minimum_required(VERSION 3.2)
project(BetterExample)

add_subdirectory(${PROJECT_SOURCE_DIR}/.. root)

# Setup a demo executable that links to the git library.
add_executable(demo main.cc)
target_link_libraries(demo CMakeGitVersion)
