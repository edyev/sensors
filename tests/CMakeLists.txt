########################
# define test executables
########################
add_executable(run_tests "")
target_sources(run_tests
    PRIVATE
        main.cpp
        test_server.cpp
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
    coverage_run_tests_dir  # Name of output directory
)