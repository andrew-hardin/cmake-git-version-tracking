#pragma once
#include <string>

class GitMetadata {
public:
  // Is the metadata populated? We may not have metadata if
  // there wasn't a .git directory (e.g. downloaded source
  // code without revision history).
  static bool Populated();

  // Were there any uncommitted changes that won't be reflected
  // in the CommitID?
  static bool AnyUncommittedChanges();

  // The commit author's name.
  static std::string AuthorName();
  // The commit author's email.
  static std::string AuthorEmail();
  // The commit SHA1.
  static std::string CommitSHA1();
  // The ISO8601 commit date.
  static std::string CommitDate();
  // The commit subject (first line of commit message).
  static std::string CommitSubject();
  // The commit notes (remaining lines in commit message).
  static std::string CommitNotes();
};