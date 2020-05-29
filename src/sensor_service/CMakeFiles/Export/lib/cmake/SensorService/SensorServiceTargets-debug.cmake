#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "SensorService::libsensor_service" for configuration "Debug"
set_property(TARGET SensorService::libsensor_service APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(SensorService::libsensor_service PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/lib/libsensor_service.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS SensorService::libsensor_service )
list(APPEND _IMPORT_CHECK_FILES_FOR_SensorService::libsensor_service "${_IMPORT_PREFIX}/lib/libsensor_service.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
