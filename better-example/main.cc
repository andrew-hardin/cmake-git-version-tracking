#include <cstdlib>
#include <iostream>

#include "git.h"

int main() {
    if(GitMetadata::Populated()) {
        if(GitMetadata::AnyUncommittedChanges()) {
            std::cerr << "WARN: there were uncommitted changes at build-time." << std::endl;
        }
        std::cout << "commit " << GitMetadata::CommitSHA1() << " (HEAD)\n"
                  << "Author: " << GitMetadata::AuthorName() << " <" << GitMetadata::AuthorEmail() << ">\n"
                  << "Date: " << GitMetadata::CommitDate() << "\n\n"
                  << GitMetadata::CommitSubject() << "\n" << GitMetadata::CommitNotes() << std::endl;
        return EXIT_SUCCESS;
    }
    else {
        std::cerr << "WARN: failed to get the current git state. Is this a git repo?" << std::endl;
        return EXIT_FAILURE;
    }
}
