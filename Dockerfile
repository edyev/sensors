# Base image:
FROM ubuntu:18.04
LABEL maintainer=" Noah Wilson <noah.wilson@ontera.bio>"

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV REPO_DIR /builds/ontera/sw-team/service_challenge
ARG GITLAB_TOKEN

# install dependencies
RUN apt-get update
RUN apt-get -y -q install --no-install-recommends \
    make
RUN mkdir -p $REPO_DIR
COPY clone_dependencies.sh $REPO_DIR
COPY Makefile $REPO_DIR
WORKDIR $REPO_DIR
RUN make bootstrap
RUN make clone_dependencies
RUN make install_dependencies
RUN rm -rf $REPO_DIR

# remove apt cache/temporary files
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*