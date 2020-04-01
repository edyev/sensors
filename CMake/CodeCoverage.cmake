#
# 2012-01-31, Lars Bilke
# - Enable Code Coverage
#
# 2013-09-17, Joakim Söderberg
# - Added support for Clang.
# - Some additional usage instructions.
#
# USAGE:

# 0. (Mac only) If you use Xcode 5.1 make sure to patch geninfo as described here:
#      http://stackoverflow.com/a/22404544/80480
#
# 1. Copy this file into your cmake modules path.
#
# 2. Add the following line to your CMakeLists.txt:
#      INCLUDE(CodeCoverage)
#
# 3. Set compiler flags to turn off optimization and enable coverage: 
#    SET(CMAKE_CXX_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
#     SET(CMAKE_C_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
#  
# 3. Use the function SETUP_TARGET_FOR_COVERAGE to create a custom make target
#    which runs your test executable and produces a lcov code coverage report:
#    Example:
#     SETUP_TARGET_FOR_COVERAGE(
#                my_coverage_target  # Name for custom target.
#                test_driver         # Name of the test driver executable that runs the tests.
#                                    # NOTE! This should always have a ZERO as exit code
#                                    # otherwise the coverage generation will not complete.
#                coverage            # Name of output directory.
#                )
#
# 4. Build a Debug build:
#     cmake -DCMAKE_BUILD_TYPE=Debug ..
#     make
#     make my_coverage_target
#
#

# Check prereqs
find_program(GCOV_PATH gcov)
find_program(LCOV_PATH lcov)
find_program(GENHTML_PATH genhtml)
find_program(GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/tests)

set(DEBUG_CXX_OPTIONS_COVERAGE -g -O0 -fprofile-arcs -ftest-coverage)

if(NOT GCOV_PATH)
    message(FATAL_ERROR "gcov not found! Aborting...")
endif()

if(NOT CMAKE_COMPILER_IS_GNUCXX)
    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang|AppleClang")
        message(FATAL_ERROR "Compiler is not GNU gcc or clang! Compiler is ${CMAKE_CXX_COMPILER_ID}. Aborting...")
    endif()
endif()

if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
  MESSAGE( WARNING "Code coverage results with an optimized (non-Debug) build may be misleading" )
endif()


# Param _targetname     The name of new the custom make target
# Param _testrunner     The name of the target which runs the tests.
#                        MUST return ZERO always, even on errors. 
#                        If not, no coverage report will be created!
# Param _outputname     lcov output is generated as _outputname.info
#                       HTML report is generated in _outputname/index.html
# Optional fourth parameter is passed as arguments to _testrunner
#   Pass them in list form, e.g.: "-j;2" for -j 2
function(SETUP_TARGET_FOR_COVERAGE _targetname _testrunner _outputname)

    if(NOT LCOV_PATH)
        message(FATAL_ERROR "lcov not found! Aborting...")
    endif()

    if(NOT GENHTML_PATH)
        message(FATAL_ERROR "genhtml not found! Aborting...")
    endif()

    # add compiler options for debug 
    target_compile_options(${_testrunner} PRIVATE "$<$<CONFIG:DEBUG>:${DEBUG_CXX_OPTIONS_COVERAGE}>")
    target_link_options(${_testrunner} PRIVATE "$<$<CONFIG:DEBUG>:${DEBUG_CXX_OPTIONS_COVERAGE}>")

    # Setup target
    add_custom_target(${_targetname}
        
        # Cleanup lcov
        ${LCOV_PATH} --directory . --zerocounters
        
        # Run tests
        COMMAND ${_testrunner} ${_outputnam}
        
        # Capturing lcov counters and generating report
        COMMAND ${LCOV_PATH} --directory . --capture --output-file ${_outputname}.info --rc lcov_branch_coverage=1
        COMMAND ${LCOV_PATH} --remove ${_outputname}.info 'build/*' 'tests/*' '/usr/*' --output-file ${_outputname}.info.cleaned
        COMMAND ${GENHTML_PATH} -o ${_outputname} ${_outputname}.info.cleaned
        COMMAND ${CMAKE_COMMAND} -E remove ${_outputname}.info ${_outputname}.info.cleaned
        
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
    )
    
    # Show info where to find the report
    add_custom_command(TARGET ${_targetname} POST_BUILD
        COMMAND ;
        COMMENT "Open ./${_outputname}/index.html in your browser to view the coverage report."
    )

endfunction() # SETUP_TARGET_FOR_COVERAGE
