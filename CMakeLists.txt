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

########################
# create protobuf
########################
# compile proto_files
set(PROTO_FILES
    proto_files/sensor_service.proto
)
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILES})

########################
# define libsensor_service build
########################
add_library(libsensor_service STATIC "")

target_sources(libsensor_service
    PRIVATE
        src/sensor_service.cpp
        ${PROTO_SRCS}
        ${PROTO_HDRS}
)

# Keep the library named as either libsensor_service.a or sensor_service.lib
# While having the target's logical name be distinct from sensor_service (the binary)
set_target_properties(libsensor_service PROPERTIES
    OUTPUT_NAME sensor_service
)

# Add a namespace alias.
# This is useful to abstract over use of the library as installed vs subdirectory build
add_library(SensorService::libsensor_service ALIAS libsensor_service)

target_compile_features(libsensor_service PUBLIC
    cxx_attributes
    cxx_defaulted_functions
    cxx_deleted_functions
    cxx_final
)
target_include_directories(libsensor_service
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/sensor_service>
    PRIVATE
        ${CMAKE_SOURCE_DIR}/src
)

# add protobuf header path(s)
foreach(PROTO_HDR ${PROTO_HDRS})
    get_filename_component(PROTO_HDR_PATH ${PROTO_HDR} DIRECTORY)
    target_include_directories(libsensor_service
        PUBLIC
            $<BUILD_INTERFACE:${PROTO_HDR_PATH}>
    )
endforeach()

target_compile_definitions(libsensor_service PUBLIC __STDC_LIMIT_MACROS __STDC_FORMAT_MACROS)

# set compiler/linker options (e.g. warning levels) for various platforms
if ( CMAKE_CXX_COMPILER_ID MATCHES "Clang|AppleClang|GNU" )
    target_compile_options(libsensor_service PRIVATE "$<$<CONFIG:DEBUG>:${DEBUG_CXX_OPTIONS}>")
    target_compile_options(libsensor_service PRIVATE "$<$<CONFIG:RELEASE>:${DEBUG_CXX_OPTIONS}>")
endif()
if ( CMAKE_CXX_COMPILER_ID MATCHES "Clang" )
    target_compile_options(libsensor_service PRIVATE "$<$<CONFIG:DEBUG>:${DEBUG_CXX_OPTIONS_CLANG}>")
    target_compile_options(libsensor_service PRIVATE "$<$<CONFIG:RELEASE>:${DEBUG_CXX_OPTIONS_CLANG}>")
endif()

target_link_libraries(libsensor_service
    PUBLIC
        protobuf::libprotobuf
        nnxx::nnxx
)

########################
# installation
########################
# set up libsensor_service install
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/SensorService)

install(
    TARGETS
        libsensor_service
    EXPORT SensorServiceTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY sensor_service/include
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/sensor_service
    FILES_MATCHING PATTERN "*.h*"
)
install(FILES ${PROTO_HDRS}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/sensor_service
)

install(EXPORT SensorServiceTargets
    FILE SensorServiceTargets.cmake
    NAMESPACE SensorService::
    DESTINATION ${INSTALL_CONFIGDIR}
)

########################
# ConfigVersion file
########################
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/SensorServiceConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/CMake/SensorServiceConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/SensorServiceConfig.cmake
    INSTALL_DESTINATION ${INSTALL_CONFIGDIR}
)

# Install all the helper files
install(
    FILES
      ${CMAKE_CURRENT_BINARY_DIR}/SensorServiceConfig.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/SensorServiceConfigVersion.cmake
    DESTINATION ${INSTALL_CONFIGDIR}
)

########################
# define server executable
########################
add_executable(server "")
target_sources(server
    PRIVATE
        src/server.cpp
)
target_link_libraries(server
    PUBLIC
        protobuf::libprotobuf
        nnxx::nnxx
        SensorService::libsensor_service
)

########################
# define client executable
########################
add_executable(client "")
target_sources(client
    PRIVATE
        src/client.cpp
)
target_link_libraries(client
    PUBLIC
        protobuf::libprotobuf
        nnxx::nnxx
        SensorService::libsensor_service
)

########################
# define test executables
########################
add_executable(run_tests "")
target_sources(run_tests
    PRIVATE
        tests/main.cpp
        tests/test_server.cpp
)
target_link_libraries(run_tests
    PUBLIC
        protobuf::libprotobuf
        nnxx::nnxx
        SensorService::libsensor_service
        gtest
)
add_test(NAME run_tests COMMAND $<TARGET_FILE:run_tests>)

include(CodeCoverage)
setup_target_for_coverage(
    coverage_run_tests      # Name for custom target.
    run_tests               # Name of the test driver executable that runs the tests.
    # NOTE! This should always have a ZERO as exit code
    # otherwise the coverage generation will not complete.
    coverage_run_tests_dir  # Name of output directory.
)