#include <iostream>
#include <cstdlib>
#include <ctime>
#include <nanomsg/nn.h>
#include <nanomsg/pair.h>
#include <string.h>
#include <inttypes.h>
#include <string>
#include <chrono>

class Client {
public:
    Client(std::string path):_socket_path(path){
        std::cout << "Client constructor" << std::endl;  
        this->_socket = nn_socket(AF_SP, NN_PAIR);
        if (this->_socket < 0)
            throw std::runtime_error("Connection failed");
        srand((unsigned) time(0));
    };
    ~Client(){
        std::cout << "Client desconstructor" << std::endl;

    };
    int bind(){
        return nn_bind(this->_socket, this->_socket_path.c_str());

    }
    int connect(){
        return nn_connect(this->_socket, this->_socket_path.c_str());
    }
    void send(std::string msg){
        nn_send(this->_socket, msg.c_str(), msg.size(), 0);
    }
protected:
    int _socket;
    std::string _socket_path;
};


class Sensor: public Client {
public:
    Sensor(std::string name, std::string path): Client(path), _name(name){
        std::cout << "Sensor type " << this->_name << std::endl;
    }

    ~Sensor(){}

    int32_t getValue(){
        return (int32_t)(rand() % 1000 - rand() % 500);
    }

    std::string getName(){
        return this->_name;
    }
    
    std::string getPayload(){
        std::string payload;
        std::time_t timestamp = 
            std::chrono::system_clock::to_time_t(
                std::chrono::system_clock::now());
        payload = std::ctime(&timestamp);
        payload = payload.substr(0, payload.size()-1);
        payload += std::string(",") + 
            this->getName() + std::string(",") + 
            std::to_string(this->getValue());

        return payload;
    }

private:
    std::string _name;
    int32_t _value;
    std::string _socket_path;

};