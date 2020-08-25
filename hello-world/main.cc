#include <cstdlib>
#include <iostream>

#include "git.h"

int main() {
    // Demo that our macros work.
    if(GIT_RETRIEVED_STATE) {
        if(GIT_IS_DIRTY) std::cerr << "WARN: there were uncommitted changes." << std::endl;

        // Print information about the commit.
        // The format imitates the output from "git log".
        std::cout << "\n\ncommit " << GIT_HEAD_SHA1 << " (HEAD)\n"
                  << "Describe: " << GIT_DESCRIBE << "\n"
                  << "Author: " << GIT_AUTHOR_NAME << " <" << GIT_AUTHOR_EMAIL << ">\n"
                  << "Date: " << GIT_COMMIT_DATE_ISO8601 << "\n\n"
                  << GIT_COMMIT_SUBJECT << "\n" << GIT_COMMIT_BODY << std::endl;
        return EXIT_SUCCESS;
    }
    else {
        std::cerr << "WARN: failed to get the current git state. Is this a git repo?" << std::endl;
        return EXIT_FAILURE;
    }
}
