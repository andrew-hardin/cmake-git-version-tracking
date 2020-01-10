#pragma once
#include <string>

class GitMetadata {
public:
  // Is the metadata populated? We may not have metadata if
  // there wasn't a .git directory (e.g. downloaded source
  // code without revision history).
  static bool Populated();

  // Get the commit id (SHA1).
  static std::string CommitID();

  // Were there any uncommitted changes that won't be reflected
  // in the CommitID?
  static bool AnyUncommittedChanges();
};