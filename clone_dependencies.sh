DEPENDENCY_DIR=dependencies

PROTOBUF_NAME=protobuf
PROTOBUF_REPO=protocolbuffers/protobuf
PROTOBUF_VER=v3.11.4

NANOMSG_NAME=nanomsg
NANOMSG_REPO=nanomsg/nanomsg
NANOMSG_VER=1.1.5

LIBUSB_NAME=libusb
LIBUSB_REPO=libusb/libusb
LIBUSB_VER=v1.0.23-rc1

function fetch_from_gitlab() {
    mkdir -p $DEPENDENCY_DIR
    if [ ! -d $DEPENDENCY_DIR/$1 ]; then
        git clone https://gitlab-ci-token:$GITLAB_TOKEN@gitlab.com/$2.git --branch $3 --depth 1 ./$DEPENDENCY_DIR/$1;
    fi
}

function fetch_from_github() {
    mkdir -p $DEPENDENCY_DIR
    if [ ! -d $DEPENDENCY_DIR/$1 ]; then
        git clone https://github.com/$2.git --branch $3 --depth 1 ./$DEPENDENCY_DIR/$1;
    fi
}

fetch_from_github $PROTOBUF_NAME $PROTOBUF_REPO $PROTOBUF_VER
fetch_from_github $NANOMSG_NAME $NANOMSG_REPO $NANOMSG_VER
fetch_from_github $LIBUSB_NAME $LIBUSB_REPO $LIBUSB_VER