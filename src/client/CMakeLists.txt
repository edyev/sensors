########################
# define client executable
########################
add_executable(client "")
target_sources(client
    PRIVATE
        client.cpp
)
target_link_libraries(client
    PUBLIC
        protobuf::libprotobuf
        nnxx::nnxx
        SensorService::libsensor_service
)
