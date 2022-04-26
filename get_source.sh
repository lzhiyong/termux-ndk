#!/bin/bash

mkdir llvm-toolchain && cd llvm-toolchain

# install repo tool
curl https://storage.googleapis.com/git-repo-downloads/repo > bin/repo
chmod a+rx bin/repo

# download the source code
bin/repo init -u https://android.googlesource.com/platform/manifest -b llvm-toolchain

# rebuild the toolchain with that manifest
cp /path/to/android-ndk-r23b/toolchains/llvm/prebuilt/linux-x86_64/manifest_7714059.xml .repo/manifests

bin/repo init -m manifest_7714059.xml

bin/repo sync -c -j4
