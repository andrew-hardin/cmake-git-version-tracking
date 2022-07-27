#include <git.h>
#include <iostream>

int main() {
    std::cout << git::CommitSHA1() << std::endl;
    return 0;
}