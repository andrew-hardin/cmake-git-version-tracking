## Instructions
1. Configure the project (`mkdir build && cd build && cmake ..`).
2. Build it (`make`).
3. Run `./demo`- note the SHA1.
4. Build it again (`make`)- note that nothing is recompiled (sweet!).
5. Edit README.md, then build and run the demo- note that the demo now reports that the HEAD is dirty.
6. Commit something, then build and run the demo- note that the SHA1 has changed.
