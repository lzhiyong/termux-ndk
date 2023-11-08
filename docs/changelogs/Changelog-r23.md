# Changelog

Report issues to [GitHub].

For Android Studio issues, follow the docs on the [Android Studio site].

[GitHub]: https://github.com/android/ndk/issues
[Android Studio site]: http://tools.android.com/filing-bugs

## Announcements

* GNU binutils is deprecated and will be removed in an upcoming NDK release.
  Note that the GNU assembler (`as`) **is** a part of this. If you are building
  with `-fno-integrated-as`, file bugs if anything is preventing you from
  removing that flag.

* [LLD](https://lld.llvm.org/) is now the default linker. ndk-build and our
  CMake toolchain file have also migrated to using llvm-ar and llvm-strip.

## Changes

## Known Issues

* This is not intended to be a comprehensive list of all outstanding bugs.
* [Issue 360]: `thread_local` variables with non-trivial destructors will cause
  segfaults if the containing library is `dlclose`ed on devices running M or
  newer, or devices before M when using a static STL. The simple workaround is
  to not call `dlclose`.
* [Issue 906]: Clang does not pass `-march=armv7-a` to the assembler when using
  `-fno-integrated-as`. This results in the assembler generating ARMv5
  instructions. Note that by default Clang uses the integrated assembler which
  does not have this problem. To workaround this issue, explicitly use
  `-march=armv7-a` when building for 32-bit ARM with the non-integrated
  assembler, or use the integrated assembler. ndk-build and CMake already
  contain these workarounds.
* [Issue 988]: Exception handling when using ASan via wrap.sh can crash. To
  workaround this issue when using libc++_shared, ensure that your
  application's libc++_shared.so is in `LD_PRELOAD` in your `wrap.sh` as in the
  following example:

  ```bash
  #!/system/bin/sh
  HERE="$(cd "$(dirname "$0")" && pwd)"
  export ASAN_OPTIONS=log_to_syslog=false,allow_user_segv_handler=1
  ASAN_LIB=$(ls $HERE/libclang_rt.asan-*-android.so)
  if [ -f "$HERE/libc++_shared.so" ]; then
      # Workaround for https://github.com/android/ndk/issues/988.
      export LD_PRELOAD="$ASAN_LIB $HERE/libc++_shared.so"
  else
      export LD_PRELOAD="$ASAN_LIB"
  fi
  "$@"
   ```

  There is no known workaround for libc++_static.

  Note that because this is a platform bug rather than an NDK bug this
  workaround will be necessary for this use case to work on all devices until
  at least Android R.
* [Issue 1130]: When using `c++_static` and the deprecated linker with ndk-build
  with an `APP_PLATFORM` below 21, undefined references to operator new may
  occur. The fix is to use LLD.
* This version of the NDK is incompatible with the Android Gradle plugin
  version 3.0 or older. If you see an error like
  `No toolchains found in the NDK toolchains folder for ABI with prefix: mips64el-linux-android`,
  update your project file to [use plugin version 3.1 or newer]. You will also
  need to upgrade to Android Studio 3.1 or newer.
* [Issue 843]: Using LLD with binutils `strip` or `objcopy` breaks RelRO. Use
   `llvm-strip` and `llvm-objcopy` instead. This issue has been resolved in
   Android Gradle Plugin version 4.0 (for non-Gradle users, the fix is also in
   ndk-build and our CMake toolchain file), but may affect other build systems.

[Issue 360]: https://github.com/android/ndk/issues/360
[Issue 843]: https://github.com/android/ndk/issues/843
[Issue 906]: https://github.com/android/ndk/issues/906
[Issue 988]: https://github.com/android/ndk/issues/988
[Issue 1130]: https://github.com/android/ndk/issues/1130
[use plugin version 3.1 or newer]: https://developer.android.com/studio/releases/gradle-plugin#updating-plugin
