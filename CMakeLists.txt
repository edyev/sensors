cmake_minimum_required(VERSION 3.13)

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

# define dependencies
find_package(Protobuf 3.11.0 REQUIRED)
find_package(Nnxx 0.2.1 REQUIRED)

########################
# create protobuf
########################
# compile proto_files
set(PROTO_FILES
    proto_files/envelope.proto
    proto_files/data_service.proto
)
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILES})

########################
# define libbasecamp_service build
########################
add_library(libbasecamp_service STATIC "")

target_sources(libbasecamp_service
    PRIVATE
        src/req_rep.cpp
        ${PROTO_SRCS}
        ${PROTO_HDRS}
)

# Keep the library named as either libbasecamp_service.a or basecamp_service.lib
# While having the target's logical name be distinct from basecamp_service (the binary)
set_target_properties(libbasecamp_service PROPERTIES
    OUTPUT_NAME basecamp_service
)

# Add a namespace alias.
# This is useful to abstract over use of the library as installed vs subdirectory build
add_library(BasecampService::libbasecamp_service ALIAS libbasecamp_service)

target_compile_features(libbasecamp_service PUBLIC
    cxx_attributes
    cxx_defaulted_functions
    cxx_deleted_functions
    cxx_final
)
target_include_directories(libbasecamp_service
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/basecamp_service>
    PRIVATE
        ${CMAKE_SOURCE_DIR}/src
)

# add protobuf header path(s)
foreach(PROTO_HDR ${PROTO_HDRS})
    get_filename_component(PROTO_HDR_PATH ${PROTO_HDR} DIRECTORY)
    target_include_directories(libbasecamp_service
        PUBLIC
            $<BUILD_INTERFACE:${PROTO_HDR_PATH}>
    )
    message(STATUS "PROTO_HDR_PATH: ${PROTO_HDR_PATH}")
endforeach()

target_compile_definitions(libbasecamp_service PUBLIC __STDC_LIMIT_MACROS __STDC_FORMAT_MACROS)

# set compiler/linker options (e.g. warning levels) for various platforms
if ( CMAKE_CXX_COMPILER_ID MATCHES "Clang|AppleClang|GNU" )
    target_compile_options(libbasecamp_service PRIVATE "$<$<CONFIG:DEBUG>:${DEBUG_CXX_OPTIONS}>")
    target_compile_options(libbasecamp_service PRIVATE "$<$<CONFIG:RELEASE>:${DEBUG_CXX_OPTIONS}>")
endif()
if ( CMAKE_CXX_COMPILER_ID MATCHES "Clang" )
    target_compile_options(libbasecamp_service PRIVATE "$<$<CONFIG:DEBUG>:${DEBUG_CXX_OPTIONS_CLANG}>")
    target_compile_options(libbasecamp_service PRIVATE "$<$<CONFIG:RELEASE>:${DEBUG_CXX_OPTIONS_CLANG}>")
endif()

target_link_libraries(libbasecamp_service
    PUBLIC
        protobuf::libprotobuf
        nnxx::nnxx
)

########################
# installation
########################
# set up libbasecamp_service install
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/BasecampService)

install(
    TARGETS
        libbasecamp_service
    EXPORT BasecampServiceTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY basecamp_service/include
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/basecamp_service
    FILES_MATCHING PATTERN "*.h*"
)
install(FILES ${PROTO_HDRS}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/basecamp_service
)

install(EXPORT BasecampServiceTargets
    FILE BasecampServiceTargets.cmake
    NAMESPACE BasecampService::
    DESTINATION ${INSTALL_CONFIGDIR}
)

########################
# ConfigVersion file
########################
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/BasecampServiceConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/CMake/BasecampServiceConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/BasecampServiceConfig.cmake
    INSTALL_DESTINATION ${INSTALL_CONFIGDIR}
)

# Install all the helper files
install(
    FILES
      ${CMAKE_CURRENT_BINARY_DIR}/BasecampServiceConfig.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/BasecampServiceConfigVersion.cmake
    DESTINATION ${INSTALL_CONFIGDIR}
)

########################
# define test executables
########################


add_executable(test_req_rep
    tests/test_req_rep.cpp
)
target_link_libraries(test_req_rep
    PUBLIC
        protobuf::libprotobuf
        nnxx::nnxx
        BasecampService::libbasecamp_service
)
add_test(NAME smoke-test COMMAND $<TARGET_FILE:test_req_rep>)