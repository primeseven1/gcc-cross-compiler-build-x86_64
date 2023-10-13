#!/usr/bin/env bash

PREFIX="$HOME/.toolchains/gcc/x86_64-elf"
TARGET="x86_64-elf"
export PATH="$PREFIX/bin:$PATH"

mkdir -p $PREFIX

mkdir cross-compiler
cd cross-compiler
curl -O https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.gz
curl -O https://ftp.gnu.org/gnu/gcc/gcc-13.1.0/gcc-13.1.0.tar.gz

tar xf binutils-2.40.tar.gz
tar xf gcc-13.1.0.tar.gz

mkdir binutils-build
mkdir gcc-build

cd binutils-build
../binutils-2.40/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install

# libgcc configs for building without the red zone
cd ..
cd gcc-13.1.0/gcc/config/i386
touch t-x86_64-elf
echo -e "MULTILIB_OPTIONS += mno-red-zone\nMULTILIB_DIRNAMES += no-red-zone" > ./t-x86_64-elf
cd ../../
# Create a backup of this in case something goes wrong
cp ./config.gcc ./config.gcc.backup
echo "Created backup config.gcc"
# This makes sure that libgcc is built correctly with the no red zone flag
sed -i 's/x86_64-\*-elf\*)/x86_64-*-elf*)\n    tmake_file="${tmake_file} i386\/t-x86_64-elf"/' config.gcc

cd ../../gcc-build
../gcc-13.1.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc

# Just in case something goes wrong here, you can restore it from the backup
cp ~/.bashrc ~/.bashrc.backup
echo "Created backup ~/.bashrc at ~/.bashrc.backup"
echo -e "\nexport PATH=\"\$HOME/.toolchains/gcc/x86_64-elf/bin:\$PATH\"" >> ~/.bashrc
