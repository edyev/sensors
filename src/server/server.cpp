#include <iostream>
#include <thread>
#include <vector>
#include "server.hpp"

void receive_thread();

int main(int argc, char *argv[])
{
    int err;
    std::vector<std::thread> threads;
    std::thread thr;
    Server* s = new Server("ipc:///tmp/__socket11.ipc");

    std::cout << "I'm a server!" << std::endl;

    err = s->bind();
    if (err < 0)
        throw std::runtime_error("Error while binding socket");
    
    err = s->connect();
    if (err < 0)
        throw std::runtime_error("Error while connecting socket");

    int i = 4;
    while(i--){
        std::cout << "Thread " << i << std::endl;
        thr = std::thread(&Server::receive, s);
        threads.push_back(std::move(thr));
    }
    std::cout << "There are threads"<< threads.size() << std::endl;
    for (auto i = threads.begin(); i != threads.end(); ++i){
        std::cout << "Joining ..." << std::endl;
        i->join();
    }

    delete s;
    return 0;
}

void receive_thread(){
    std::cout << __func__ << std::endl;
}

