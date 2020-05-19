########################
# define server executable
########################
add_executable(server "")
target_sources(server
    PRIVATE
        server.cpp
)
target_link_libraries(server
    PUBLIC
        protobuf::libprotobuf
        nnxx::nnxx
        SensorService::libsensor_service
)
