cmake_minimum_required(VERSION 3.8)

include(GNUInstallDirs)

project(libbasecamp_service VERSION 0.1.0 LANGUAGES CXX)

# use C++14 standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# define compiler flags for different build modes
set(DEBUG_CXX_OPTIONS -Wall -Wextra -Wunreachable-code -Wpedantic)
set(DEBUG_CXX_OPTIONS_CLANG -Wweak-vtables -Wexit-time-destructors -Wglobal-constructors -Wmissing-noreturn)
set(RELEASE_CXX_OPTIONS -Wall -Wextra -Wunreachable-code -Wpedantic)
set(RELEASE_CXX_OPTIONS_CLANG -Wweak-vtables -Wexit-time-destructors -Wglobal-constructors -Wmissing-noreturn)

# Set the searching location for cmake 'include' locations
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/CMake")

add_subdirectory(libbasecamp_service)