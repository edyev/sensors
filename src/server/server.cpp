#include <iostream>
#include <thread>
#include <vector>
#include "server.hpp"

#define MAX_THREADS 8

int main(int argc, char *argv[])
{
    int err;
    std::vector<std::thread> threads;
    std::thread thr;
    Server* s = new Server("ipc:///tmp/__socket12.ipc");

    err = s->bind();
    if (err < 0)
        throw std::runtime_error("Error while binding socket");
    
    err = s->connect();
    if (err < 0)
        throw std::runtime_error("Error while connecting socket");

    while(1){
        for(int i = 0; i < MAX_THREADS; ++i){
            thr = std::thread(&Server::receive, s);
            threads.push_back(std::move(thr));

        }

        for (auto i = threads.begin(); i != threads.end(); ++i){
            if(i->joinable()){
                i->join();
            }

        }
        threads.empty();
    }
    delete s;
    return 0;
}



