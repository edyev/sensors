#include "req_rep.hpp"
#include "gtest/gtest.h"

std::string nanomsg_sample(std::string input_str)
{
    std::cout << "Running test..." << std::endl;

    try
    {
        nnxx::socket s1{nnxx::SP, nnxx::PAIR};
        nnxx::socket s2{nnxx::SP, nnxx::PAIR};
        const char *addr = "inproc://example";

        s1.bind(addr);
        s2.connect(addr);

        s1.send(input_str);

        nnxx::message msg = s2.recv();
        std::cout << msg << std::endl;

        return nnxx::to_string(msg);
    }
    catch (const std::system_error &e)
    {
        std::cerr << e.what() << std::endl;
        return nullptr;
    }
}

namespace
{
TEST(NanomsgTest, BasicSample)
{
    std::string input_string = "Hello World!";
    std::string output_string = nanomsg_sample(input_string);

    std::cout << "Input string: " << input_string << std::endl;
    std::cout << "Output string: " << output_string << std::endl;

    //EXPECT_STREQ(output_string, input_string);
}

} // namespace