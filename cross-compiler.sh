#!/usr/bin/env bash

GCC_VERSION="13.1.0"
BINUTILS_VERSION="2.40"

PREFIX="$HOME/.toolchains/gcc/x86_64-elf-testing"
TARGET="x86_64-elf"
export PATH="$PREFIX/bin:$PATH"

MAKE_J_FLAG="-j8"

mkdir -p $PREFIX

mkdir cross-compiler
cd cross-compiler
curl -O https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz
curl -O https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz

tar xf binutils-$BINUTILS_VERSION.tar.gz
tar xf gcc-$GCC_VERSION.tar.gz

mkdir binutils-build
mkdir gcc-build

cd binutils-build
../binutils-$BINUTILS_VERSION/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make $MAKE_J_FLAG
make install $MAKE_J_FLAG

cd ..
cd gcc-$GCC_VERSION/gcc/config/i386

# Need this for building libgcc without the red zone
touch t-x86_64-elf
echo -e "MULTILIB_OPTIONS += mno-red-zone\nMULTILIB_DIRNAMES += no-red-zone" > ./t-x86_64-elf
cd ../../

# This makes sure that when building, it uses the t-x86_64-elf file for building libgcc without the red zone
sed -i 's/x86_64-\*-elf\*)/x86_64-*-elf*)\n    tmake_file="${tmake_file} i386\/t-x86_64-elf"/' config.gcc

cd ../../gcc-build
../gcc-$GCC_VERSION/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc $MAKE_J_FLAG
make all-target-libgcc $MAKE_J_FLAG
make install-gcc $MAKE_J_FLAG
make install-target-libgcc $MAKE_J_FLAG

# Just in case something goes wrong here, you can restore it from the backup
cp ~/.bashrc ~/.bashrc.backup
echo "Created backup ~/.bashrc at ~/.bashrc.backup"
echo -e "\nexport PATH=\"\$HOME/.toolchains/gcc/x86_64-elf/bin:\$PATH\"" >> ~/.bashrc
