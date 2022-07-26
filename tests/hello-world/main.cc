#include <cstdlib>
#include <iostream>

#include "git.h"

int main() {
    if(git::IsPopulated()) {
        if(git::AnyUncommittedChanges()) {
            std::cerr << "WARN: there were uncommitted changes at build-time." << std::endl;
        }
        std::cout << "commit " << git::CommitSHA1() << " (" << git::Branch() << ")\n"
                  << "describe " << git::Describe() << "\n"
                  << "Author: " << git::AuthorName() << " <" << git::AuthorEmail() << ">\n"
                  << "Date: " << git::CommitDate() << "\n\n"
                  << git::CommitSubject() << "\n" << git::CommitBody() << std::endl;
        return EXIT_SUCCESS;
    }
    else {
        std::cerr << "WARN: failed to get the current git state. Is this a git repo?" << std::endl;
        return EXIT_FAILURE;
    }
}
