#include <iostream>
#include "client.hpp"

int main(int argc, char *argv[])
{   
    std::string msg; 
    Sensor* sensor;
    if(argc < 2)
        sensor = new Sensor("temp", "ipc:///tmp/__socket12.ipc");
    else
        sensor = new Sensor(argv[1],  "ipc:///tmp/__socket12.ipc");
    std::cout << "Value:" << sensor->getValue() << std::endl;
    sensor->bind();
    sensor->connect();
    sensor->send(sensor->getPayload());
    delete sensor;
    return 0;
}
