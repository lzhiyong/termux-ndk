# Working with the NDK Toolchains

The latest version of this document is available at
https://android.googlesource.com/platform/ndk/+/master/docs/Toolchains.md.

The toolchains shipped in the NDK are not built as a part of the NDK build
process. Instead they are built separately and checked into git as prebuilts
that are repackaged when shipped in the NDK. This applies to both Clang and
binutils.

Both toolchains are built separately. An artifact of the build is a tarball of
the compiler for distribution. That artifact is unpacked into a location in the
Android tree and checked in. The NDK build step for the toolchain copies that
directory into the NDK and makes minor modifications to make the toolchains suit
the NDK rather than the platform.

Note: Any changes to either toolchain need to be tested in the platform *and*
the NDK. The platform and the NDK both get their toolchains from the same build.

TODO: This process is far too manual. `checkbuild.py` should be updated (or
additional scripts added) to ease this process.

## Clang

Clang's build process is described in the [Android LLVM Readme]. Note that Clang
cannot be built from the NDK tree. The output tarball is extracted to
`prebuilts/clang/host/$HOST/clang-$REVISION`. `checkbuild.py clang` repackages
this into the NDK out directory.

[Android Clang Readme]: https://android.googlesource.com/toolchain/llvm_android/+/master/README.md

### Testing Local Changes

To test a Clang you just built:

```bash
$ export CLANG_PREBUILTS=`realpath ../prebuilts/clang/host/linux-x86`
$ rm -r $CLANG_PREBUILTS/clang-dev
$ tar xf path/to/clang-dev-linux-x86_64.tar.bz2 -C $CLANG_PREBUILTS
# Update CLANG_VERSION in ndk/toolchains.py.
$ ./checkbuild.py
# Run tests. To run the NDK test suite, you will need to attach the
# appropriately configured devices. The test tool will print warnings for
# missing configurations.
$ ./run_tests.py
```

For details about running tests, see [Testing.md].

[Testing.md]: Testing.md

This installs the new Clang into the prebuilts directory so it can be included
in the NDK. The `symlink-clang.py` line updates the symlinks in prebuilts NDK to
point at the new Clang. The Clang in `prebuilts/ndk` is used by legacy NDK build
scripts in ndk/build/tools. The difference between it and `prebuilts/clang` is
the directory layout, which differs so that `ndk-build` can use it.

If you need to make changes to Clang after running the above steps, future
updates can be done more quickly with:

```bash
$ rm -r $CLANG_PREBUILTS/clang-dev
$ tar xf path/to/clang-dev-linux-x86_64.bz2 -C $CLANG_PREBUILTS
$ ./checkbuild.py toolchain --force-package
# Run tests.
```

We don't need to rebuild the whole NDK since we've already built most of it.

### Updating to a New Clang

These steps need to be run after installing the new prebuilt from the build
server to `prebuilts/clang` (see the [update-prebuilts.py]).

[update-prebuilts.py]: https://android.googlesource.com/toolchain/llvm_android/+/master/update-prebuilts.py

```bash
# Edit ndk/toolchains.py and update `CLANG_VERSION`. When you modify this value,
also follow the instructions in the comment.
# Update the VERSION variable in get_llvm_toolchain_binprefix in
# build/tools/prebuilt-common.sh.
$ ./checkbuid.py # `--module clang` to build just Clang.
# Run tests.
```

## Binutils

Binutils is built using the [build.py] script in the toolchain/binutils.

Unlike Clang, binutils can be built from the NDK tree. The output tarball is
extracted to `prebuilts/ndk/binutils/$HOST/binutils-$ARCH-$HOST`. Like Clang,
this is built with `checkbuild.py toolchain`.

[build.py]: https://android.googlesource.com/toolchain/binutils/+/master/build.py

### Testing Local Changes

To test a GCC you just built:

```bash
$ export INSTALL_DIR=`realpath ../prebuilts/ndk/binutils/$HOST`
$ rm -r INSTALL_DIR/binutils-$ARCH-$HOST
$ unzip ../out/dist/binutils-$ARCH-$HOST.zip -d $INSTALL_DIR
$ ./checkbuild.py
# Run tests.
```

For details about running tests, see [Testing.md].

Since the NDK is already built, additional changes will not require a full
`checkbuild.py`. Instead:

```bash
$ ./checkbuild.py toolchain
# Run tests.
```

### Updating to a New Binutils

```bash
$ ../prebuilts/ndk/update_binutils.py $BUILD_NUMBER
$ ./checkbuild.py
# Run tests.
```
