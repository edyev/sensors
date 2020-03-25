cmake_minimum_required(VERSION 3.5)

include(GNUInstallDirs)

project(basecamp_service VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

########################
# define libbasecamp_service build
########################
add_library(libbasecamp_service STATIC
    libbasecamp_service/src/req_rep.cpp
)

# Keep the library named as either libbasecamp_service.a or basecamp_service.lib
# While having the target's logical name be distinct from basecamp_service (the binary)
set_target_properties(libbasecamp_service PROPERTIES
    OUTPUT_NAME basecamp_service
)

# Add a namespace alias.
# This is useful to abstract over use of the library as installed vs subdirectory build
add_library(BasecampService::libbasecamp_service ALIAS libbasecamp_service)

source_group("Source Files" FILES libbasecamp_service/src/req_rep.cpp)
target_compile_features(libbasecamp_service PUBLIC
    cxx_attributes
    cxx_defaulted_functions
    cxx_deleted_functions
    cxx_final
)
target_include_directories(libbasecamp_service
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/libbasecamp_service/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/basecamp_service>
)
target_compile_definitions(libbasecamp_service PUBLIC  __STDC_LIMIT_MACROS __STDC_FORMAT_MACROS)

# set warning levels for various platforms
if ( CMAKE_CXX_COMPILER_ID MATCHES "Clang|AppleClang|GNU" )
    target_compile_options(libbasecamp_service PRIVATE -Wall -Wextra -Wunreachable-code -Wpedantic)
endif()
if ( CMAKE_CXX_COMPILER_ID MATCHES "Clang" )
    target_compile_options(libbasecamp_service PRIVATE -Wweak-vtables -Wexit-time-destructors -Wglobal-constructors -Wmissing-noreturn)
endif()
if ( CMAKE_CXX_COMPILER_ID MATCHES "MSVC" )
    target_compile_options(libbasecamp_service PRIVATE /W4 /w44265 /w44061 /w44062)
endif()

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
include(CTest)
add_executable(test_req_rep
    libbasecamp_service/tests/test_req_rep.cpp
)
add_test(NAME smoke-test COMMAND $<TARGET_FILE:test_req_rep>)