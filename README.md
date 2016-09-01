# clementine-build
Building clementine with Docker (currently only the Windows version)

**CAUTION: This is a Work in Progress**

## Prerequisites

On the host system, run (as root):
```bash
# echo ':DOSWin:M::MZ::/usr/bin/wine:' > /proc/sys/fs/binfmt_misc/register
```
This will tell Linux (also inside the Docker containers) to execute Windows executables (`.exe`) using Wine.
