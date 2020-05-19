cmake_minimum_required(VERSION 3.13)

include(GNUInstallDirs)

project(libsensor_service VERSION 0.1.0 LANGUAGES CXX)

# use C++14 standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# define compiler flags for different build modes
set(DEBUG_CXX_OPTIONS -g -O0 -Wall -Wextra -Wunreachable-code -Wpedantic)
set(DEBUG_CXX_OPTIONS_CLANG -g -O0 -Wweak-vtables -Wexit-time-destructors -Wglobal-constructors -Wmissing-noreturn)
set(RELEASE_CXX_OPTIONS -Wall -Wextra -Wunreachable-code -Wpedantic)
set(RELEASE_CXX_OPTIONS_CLANG -Wweak-vtables -Wexit-time-destructors -Wglobal-constructors -Wmissing-noreturn)

# Set the searching location for cmake 'include' locations
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/CMake")

########################
# fetch dependencies
########################
include(FetchContent)

# google test
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG        release-1.10.0
)

FetchContent_GetProperties(googletest)
if(NOT googletest_POPULATED)
  FetchContent_Populate(googletest)
  add_subdirectory(${googletest_SOURCE_DIR} ${googletest_BINARY_DIR})
endif()

# define dependencies
find_package(Protobuf 3.11.0 REQUIRED)
find_package(Nnxx 0.2.1 REQUIRED)

# add targets
add_subdirectory(src/sensor_service)
add_subdirectory(src/client)
add_subdirectory(src/server)
add_subdirectory(tests)
