#include <iostream>
#include <nanomsg/nn.h>
#include <nanomsg/pipeline.h>

class Server {
    Server(){
        std::cout << "Server constructor" << std::endl;
    };
    ~Server(){
        std::cout << "Server desconstructor" << std::endl;

    }
private:
    int socket;

};