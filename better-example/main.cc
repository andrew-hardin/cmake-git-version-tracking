#include <cstdlib>
#include <iostream>

#include "git.h"

int main() {
    if(GitMetadata::Populated()) {
        std::cout << "INFO: " << GitMetadata::CommitID() << std::endl;
        if(GitMetadata::AnyUncommittedChanges()) {
            std::cerr << "WARN: there were uncommitted changes." << std::endl;
        }
        return EXIT_SUCCESS;
    }
    else {
        std::cerr << "WARN: failed to get the current git state. Is this a git repo?" << std::endl;
        return EXIT_FAILURE;
    }
}
