Android ndk for Termux
requirement
* architecture: aarch64
* os version: android 9 and above 

The source code from AOSP [llvm-toolchain](https://android.googlesource.com/toolchain/llvm-project), which is consistent with the official Ndk version.

At first, we don‘t need to rebuild the whole Ndk, since google already built most of it.
so we only need to build the llvm toolchain, then replace the llvm inside Ndk.

For more details information, please refer to [toolchain readme docs](https://github.com/Lzhiyong/termux-ndk/tree/master/docs)

##### [download r23b](https://github.com/Lzhiyong/termux-ndk/releases)

####  How to build

In order to save storage , there are some prebuilts tools that do not need to be downloaded. 
comment out them in the llvm-toolchain/.repo/manifests/default.xml file, click [here](https://github.com/Lzhiyong/termux-ndk/blob/master/patches/repo/default.xml.patch) for example.

```bash

# install repo, now python supports multiprocessing module
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/../usr/bin/repo
chmod a+rx ~/../usr/bin/repo

cd /data/data/com.termux/files/home 
mkdir llvm-toolchain && cd llvm-toolchain

# download the source code
repo init -u https://android.googlesource.com/platform/manifest -b llvm-toolchain

# for china
repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest -b llvm-toolchain

# rebuild the toolchain with that manifest
cp /path/to/android/android-ndk-r23b/toolchains/llvm/prebuilt/linux-x86_64/manifest_7714059.xml .repo/manifests
repo init -m manifest_7714059.xml

repo sync -c -j4

```
 ****

Install some build-essential packages, then copy or soft link it to llvm-toolchain/prebuilts

I recommend compiling on PC, because compiling on device will take a long time</br>
If compiling on PC, we only replece the prebuilt clang toolchain

```bash

# remove clang-bootstrap 
rm -vrf llvm-toolchain/prebuilts/clang/host/linux-x86/clang-bootstrap

# extract android-ndk-r23b.tar.xz to /path/to/clang-bootstrap
tar -xJvf android-ndk-r23b.tar.xz -C llvm-toolchain/prebuilts/clang/host/linux-x86/clang-bootstrap

# soft link cmake to llvm-toolchain/prebuilts
ln -sf /data/data/com.termux/files/usr/bin/cmake llvm-toolchain/prebuilts/cmake/linux-x86/bin/cmake

# soft link make to llvm-toolchain/prebuilts
ln -sf /data/data/com.termux/files/usr/bin/make llvm-toolchain/prebuilts/build-tools/linux-x86/bin/make

# soft link ninja to llvm-toolchain/prebuilts
ln -sf /data/data/com.termux/files/usr/bin/ninja llvm-toolchain/prebuilts/build-tools/linux-x86/bin/ninja

# remove prebuilt python
rm -vrf llvm-toolchain/prebuilts/python/linux-x86/*
# apt download python3
# extract python_3.9.x_aarch64.deb to llvm-toolchain/prebuilts/python/linux-x86

# building golang
apt install golang
cd llvm-toolchain/prebuilts/go/linux-x86/src
./make.bash

```

 **** 
####  Building start!

```bash
# no build for windows
# If it is not the first time to build, you can add options --skip-source-setup to save time
python toolchain/llvm_android/build.py --no-build windows --skip-source-setup
```

llvm-toolchain stage1 and stage2 compilation will take a long time.

there may be some errors during the compilation process, please solve it by yourself!

 **** 
 
#### Building finish!
```bash
# test the ndk clang
NDK_TOOLCHAIN=/path/to/android-ndk-r23b/toolchains/llvm/prebuilt/linux-aarch64
$NDK_TOOLCHAIN/bin/aarch64-linux-android28-clang++ test.cpp -o test

# if you want to use clang alone, you need to specify --target=<arch_api_level>
# for example android api 28 --target=aarch64-linux-android28
$NDK_TOOLCHAIN/bin/clang++ --target=aarch64-linux-android28 test.cpp -o test

# Note: <arch_api_level>-clang is recommended, instead of clang alone

```
 **** 

 **** 
#### Building shader-tools
```bash
cd /path/to/your_dir

# clone the source code
git clone --depth=1 https://github.com/google/shaderc
cd shaderc/third_party
git clone --depth=1 https://github.com/KhronosGroup/SPIRV-Tools.git   spirv-tools
git clone --depth=1 https://github.com/KhronosGroup/SPIRV-Headers.git spirv-tools/external/spirv-headers
git clone --depth=1 https://github.com/google/googletest.git
git clone --depth=1 https://github.com/google/effcee.git
git clone --depth=1 https://github.com/google/re2.git
git clone --depth=1 https://github.com/KhronosGroup/glslang.git

# start building shaderc...

mkdir build && cd build

# setting android ndk toolchain
TOOLCHAIN=/path/to/android-ndk-r23b/toolchains/llvm/prebuilt/linux-aarch64

cmake -G "Ninja" \
    -DCMAKE_C_COMPILER=$TOOLCHAIN/bin/aarch64-linux-android28-clang \
    -DCMAKE_CXX_COMPILER=$TOOLCHAIN/bin/aarch64-linux-android28-clang++ \
    -DCMAKE_SYSROOT=$TOOLCHAIN/sysroot \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/path/to/shader-tools \
    ..

ninja -j16
```

 **** 

#### Building app
**building android app with termux-ndk, please refer to [build-app](https://github.com/Lzhiyong/termux-ndk/tree/master/build-app)**

#### Building cocos2d game
**building cocos2d game for android with termux-ndk, please refer to [cocos2d-game](https://github.com/Lzhiyong/termux-ndk/tree/master/cocos2d-game)**

### FAQ

* I don't compile the Linux-aarch64 version only for Android.</br>
* Termux now has many packages, including `Openjdk-17` `Gradle` `Kotlin` and so on.</br>
so in most of cases we don't need to use proot linux.
