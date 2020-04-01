#ifndef REQ_REP_H
#define REQ_REP_H

#include <iostream>
#include <nnxx/message.h>
#include <nnxx/pair.h>
#include <nnxx/socket.h>
#include "basecamp_service.hpp"
#include "envelope.pb.h"
#include "data_service.pb.h"

// TODO: add logging
// TODO: load common config with endpoints and other settings
// TODO: create thread for request server (threading event to stop/exit)

class req_rep
{
public:
    req_rep(void);
    ~req_rep(void);
    int start_server(void);
    int stop_server(void);
    int get_requests(void);
    char *handle_message(char *packed_message);

private:
    const char *request_endpoint;
    nnxx::socket req_socket;
    // TODO: create map to map message type to callback
};

#endif // REQ_REP_H
