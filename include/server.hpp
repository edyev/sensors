#include <iostream>
#include <nanomsg/nn.h>
#include <nanomsg/pair.h>
#include <string.h>
#include <string>
#include <sqlite/sqlite3.h>

class Server {
public:
    Server(std::string path): _socket_path(path){
        int err;
        std::cout << "Server constructor" << std::endl;
        this->_socket = nn_socket(AF_SP, NN_PAIR);
        if (this->_socket < 0)
            throw std::runtime_error("Server Socket Connection failed");

    };
    ~Server(){
        std::cout << "Server desconstructor" << std::endl;

    }
    int bind (){
        return nn_bind(this->_socket, this->_socket_path.c_str());

    }
    int connect(){
        return nn_connect(this->_socket, this->_socket_path.c_str());
    }   

    void receive(){
        std::string data;
        char* buf = nullptr;
        int bytes;
        std::cout << "receiving" << std::endl;
        bytes = nn_recv(this->_socket, &buf, NN_MSG, 0);
        if (bytes < 0)
            throw std::runtime_error("Error rcv");

        data = std::string(buf);
        std::cout << "Received data:" << data << std::endl;
        nn_freemsg(buf);
    }
    void insertToDB(std::string data){

    }

private:
    int _socket;
    std::string _socket_path;
};