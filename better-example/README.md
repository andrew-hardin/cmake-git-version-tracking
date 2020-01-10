## Better Example
This example builds on "Hello World" by demonstrating how git
metadata can be baked into a source file instead of a header.
The intent is that improves the performance of partial rebuilds
by only rebuilding *one* object file after the git state changes.

Here's how to tryout the demo:
1. Configure the project (`mkdir build && cd build && cmake ..`).
2. Build it (`make`).
3. Run `./demo`- note the printed commit ID.
4. Build it again (`make`)- note that nothing is recompiled (sweet!).
5. Edit README.md, then build and run the demo- note that the demo now reports that the HEAD is dirty.
6. Commit something, then build and run the demo- note that the SHA1 has changed.
