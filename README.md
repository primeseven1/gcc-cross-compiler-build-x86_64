# gcc-cross-compiler-build-x86_64

This shell script will compile binutils and gcc from source. This script builds gcc 13.1.0. If you need to change that, you can just replace every 13.1.0 with whatever version you want.
This script is mainly for people who want to build an OS for the x86_64 architecture, but don't have a cross compiler yet.

Before you start, install these dependencies so the build doesn't fail:
Arch:
- base-devel
- gmp
- libmpc
- mpfr

Debian/Ubuntu:
- build-essential
- bison
- flex
- libgmp3-dev
- libmpc-dev
- libmpfr-dev
- texinfo

Fedora:
- gcc
- gcc-c++
- make
- bison
- flex
- gmp-devel
- libmpc-devel
- mpfr-devel
- texinfo

Here is what the shell script does exactly:

- Builds binutils and gcc
- Builds libgcc without the red zone (Do not forget to link with this version of libgcc, it's in: <x86_64-elf-gcc_dir>/lib/gcc/x86_64-elf/<gcc-version>/no-red-zone/libgcc.a)
- Modify your PATH variable in your .bashrc, a backup is created at ~/.bashrc.backup
- Installed at: ~/.toolchains/gcc/x86_64-elf.
