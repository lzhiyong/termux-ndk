#!/bin/bash

# clone the source code
git clone --depth=1 https://github.com/google/shaderc

git clone --depth=1 https://github.com/KhronosGroup/SPIRV-Tools.git   shaderc/third_party/spirv-tools

git clone --depth=1 https://github.com/KhronosGroup/SPIRV-Headers.git shaderc/third_party/spirv-tools/external/spirv-headers

git clone --depth=1 https://github.com/google/googletest.git shaderc/third_party/googletest

git clone --depth=1 https://github.com/google/effcee.git shaderc/third_party/effcee

git clone --depth=1 https://github.com/google/re2.git shaderc/third_party/re2

git clone --depth=1 https://github.com/KhronosGroup/glslang.git shaderc/third_party/glslang

# start building shaderc...
cd shaderc && mkdir build && cd build

# setup ndk toolchain
TOOLCHAIN=/path/to/android-ndk-r23b/toolchains/llvm/prebuilt/linux-x86_64

cmake -G "Ninja" \
    -DCMAKE_C_COMPILER=$TOOLCHAIN/bin/aarch64-linux-android28-clang \
    -DCMAKE_CXX_COMPILER=$TOOLCHAIN/bin/aarch64-linux-android28-clang++ \
    -DCMAKE_SYSROOT=$TOOLCHAIN/sysroot \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/path/to/shader-tools \
    ..

ninja -j16
