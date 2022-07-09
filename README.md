**Android ndk for Termux(only supports aarch64 and Android 9 or above)**

The source code from AOSP [llvm-toolchain](https://android.googlesource.com/toolchain/llvm-project), which is consistent with the official NDK version.

At first, we don‘t need to rebuild the whole NDK, since google already built most of it.
so we only need to build the llvm toolchain, then replace the llvm inside NDK.

How to build, please refer to [toolchain readme docs](https://github.com/Lzhiyong/termux-ndk/tree/master/docs)

Building on device is not recommended and you may encounter some strange errors.

 **** 

Building `android app` with termux-ndk, please refer to [build-app](https://github.com/Lzhiyong/termux-ndk/tree/master/build-app)

Building `cocos2d game` for android with termux-ndk, please refer to [cocos2d-game](https://github.com/Lzhiyong/termux-ndk/tree/master/cocos2d-game)

I don't provide the `linux` and `32-bit` versions, because there is not enough time to maintain, please try to compile it by yourself!!

