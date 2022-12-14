String init = """
#include <stack>
#include <string>
#include <vector>
#include <cmath>
#include <time.h>
#include <chrono>
#include <thread>
#include <iostream>
#include <fstream>

struct value
{
    std::string type;
    std::string value;
};

std::stack<value> stack;

void panic(std::string cmd, std::string msg)
{
    std::cout << "\\n\\033[1;31m[PANIC] " << msg << std::endl;
    std::cout << "[FAILED] `" << cmd << "` \\033[0m" << std::endl;
    exit(1);
}

value IFPOP() { 
    value v = stack.top();
    stack.pop();
    return v;
}

void findAndReplaceAll( std::string& data,  
                        const std::string& match,  
                        const std::string& replace) 
{ 
   // Get the first occurrence 
   size_t pos = data.find(match); 
 
   // Repeat till end is reached 
   while( pos != std::string::npos) 
    { 
        data.replace(pos, match.size(), replace); 
      
       // Get the next occurrence from the current position 
        pos = data.find(match, pos+replace.size()); 
    } 
}

const std::string WHITESPACE = " \\n\\r\\t\\f\\v";

std::string ltrim(const std::string &s)
{
    size_t start = s.find_first_not_of(WHITESPACE);
    return (start == std::string::npos) ? "" : s.substr(start);
}

std::string rtrim(const std::string &s)
{
    size_t end = s.find_last_not_of(WHITESPACE);
    return (end == std::string::npos) ? "" : s.substr(0, end + 1);
}

std::string trim(const std::string &s)
{
    return rtrim(ltrim(s));
}

""";
