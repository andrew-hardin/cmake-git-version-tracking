#include <git.h>
#include <stdio.h>

int main() {
    printf("%s\n", git_CommitSHA1());
    return 0;
}