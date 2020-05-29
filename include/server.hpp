#include <iostream>
#include <nanomsg/nn.h>
#include <nanomsg/pair.h>
#include <string.h>
#include <string>
//#include "sqlite/sqlite3.h"

class Server {
public:
    Server(std::string path): _socket_path(path){
        int err;
        this->_socket = nn_socket(AF_SP, NN_PAIR);
        if (this->_socket < 0)
            throw std::runtime_error("Server Socket Connection failed");
        std::cout << "Server created successfully!" << std::endl;


    };
    ~Server(){

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
        bytes = nn_recv(this->_socket, &buf, NN_MSG, 0);
        if (bytes < 0)
            throw std::runtime_error("Error rcv");

        data = std::string(buf);
        insertToDB(data);
        nn_freemsg(buf);
    }
    int insertToDB(std::string data){
        int err = 0;
        char* zErrMsg = 0;
        data.insert(0, std::string("insert into sensordat values ("));
        data.append(");");
        //err = sqlite3_open("sensors.db", &db);
        std::cout << "db_cmd:" << data << std::endl;
        /*if (err)
            std::cout << "Error while opening db" << std::endl;
        err = sqlite3_exec(db, data.c_str(), NULL, 0, &zErrMsg);
        if (err != SQLITE_OK){
            std::cout << "Error while inserting" << std::endl;
            sqlite3_free(zErrMsg);
        }*/

    }

private:
    int _socket;
    std::string _socket_path;
    //sqlite3* db;
};