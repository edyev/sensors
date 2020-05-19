########################
# create protobuf
########################
# compile proto_files
set(PROTO_FILES
    sensor_service.proto
)
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILES})