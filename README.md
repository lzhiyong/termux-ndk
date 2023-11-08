**Android ndk for Termux(only supports aarch64 and Android 9 or above)**

The source code from AOSP [llvm-toolchain](https://android.googlesource.com/toolchain/llvm-project), which is consistent with the official NDK version.

At first, we don‘t need to rebuild the whole NDK, since google already built most of it.
so we only need to build the llvm toolchain, then replace the llvm inside NDK.

Building the `android-ndk`, please refer to [Android Clang/LLVM Toolchain Readme Doc](https://android.googlesource.com/toolchain/llvm_android/+/master/README.md)

Packaging and testing the `android-ndk`, please refer to [Ndk Toolchains Readme Doc](https://android.googlesource.com/platform/ndk/+/master/docs/Toolchains.md)

Building `android app` with termux-ndk, please refer to [build-app](https://github.com/Lzhiyong/termux-ndk/tree/master/build-app)
