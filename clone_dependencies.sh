#!/bin/bash

DEPENDENCY_DIR=extern

NANOMSG_NAME=nanomsg
NANOMSG_REPO=nanomsg/nanomsg
NANOMSG_VER=1.1.5

NANOMSGXX_NAME=nanomsgxx
NANOMSGXX_REPO=noahness/nanomsgxx
NANOMSGXX_VER=feature/export_target_cmake

CXXOPTS_NAME=cxxopts
CXXOPTS_REPO=jarro2783/cxxopts
CXXOPTS_VER=v2.2.0

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

fetch_from_github $NANOMSG_NAME $NANOMSG_REPO $NANOMSG_VER
fetch_from_github $NANOMSGXX_NAME $NANOMSGXX_REPO $NANOMSGXX_VER
fetch_from_github $CXXOPTS_NAME $CXXOPTS_REPO $CXXOPTS_VER