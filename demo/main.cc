#include <cstdlib>
#include <iostream>

#include "git.h"

int main() {
    // Demo that our macros work.
    if(GIT_RETRIEVED_STATE) {
        std::cout << "INFO: ";
        if(VERSION_MAJOR != -1) std::cout << VERSION_MAJOR;
        if(VERSION_MINOR != -1) std::cout << "." << VERSION_MINOR;
        if(VERSION_PATCH != -1) std::cout << "." << VERSION_PATCH;
        std::cout << " (" << GIT_HEAD_SHA1 << ")"<< std::endl;
        if(GIT_IS_DIRTY) std::cerr << "WARN: there were uncommitted changes." << std::endl;
        return EXIT_SUCCESS;
    }
    else {
        std::cerr << "WARN: failed to get the current git state. Is this a git repo?" << std::endl;
        return EXIT_FAILURE;
    }
}
