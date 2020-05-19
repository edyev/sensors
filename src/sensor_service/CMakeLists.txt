########################
# create protobuf
########################
# compile proto_files
set(PROTO_FILES
    ${CMAKE_SOURCE_DIR}/proto_files/sensor_service.proto
)
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILES})

########################
# define libsensor_service build
########################
add_library(libsensor_service STATIC "")

target_sources(libsensor_service
    PRIVATE
        sensor_service.cpp
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
    ${CMAKE_SOURCE_DIR}/CMake/SensorServiceConfig.cmake.in
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
