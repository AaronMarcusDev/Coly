String init = """
#include <stack>
#include <string>
#include <iostream>

void panic(std::string cmd, std::string msg)
{
    std::cout << "\\033[1;31m[PANIC] " << msg << std::endl;
    std::cout << "[FAILED] `" << cmd << "` \\033[0m" << std::endl;
    exit(1);
}

struct value
{
    std::string type;
    std::string value;
};
""";
