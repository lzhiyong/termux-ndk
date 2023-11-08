# Changelog

Report issues to [GitHub].

For Android Studio issues, follow the docs on the [Android Studio site].

[GitHub]: https://github.com/android/ndk/issues
[Android Studio site]: http://tools.android.com/filing-bugs

## Announcements

* GNU binutils is deprecated and will be removed in an upcoming NDK release.
  Note that the GNU assembler (`as`) **is** a part of this. If you are building
  with `-fno-integrated-as`, file bugs if anything is preventing you from
  removing that flag. If you're using `as` directly, use `clang` instead.

* [LLD](https://lld.llvm.org/) is now the default linker. ndk-build and our
  CMake toolchain file have also migrated to using llvm-ar and llvm-strip.

  See the Changes section below for more information.

## Changes

* Updated LLVM to r399163b, based on LLVM 11 development.
  * [Issue 829]: Fixed issue with `__attribute__((visibility("hidden")))`
    symbols sometimes not being hidden.
  * [Issue 1149]: Fixed Clang crash with `#pragma detect_mismatch`.
  * [Issue 1212]: Fixed llvm-strip to match GNU behavior for removing file
    symbols.
  * [Issue 1248]: Fixed LLD Neon crash.
  * [Issue 1303]: Fixed Neon intrinsic optimizer crash.

* Updated make to 4.3.

* Updated libc++, libc++abi, and libunwind to
  https://github.com/llvm/llvm-project/commit/52ec983895436089c5be0b0c4d967423db16045b.

* [Issue 609]: `std::filesystem` support is now included. There are two known
  issues:
      * [Issue 1258]: `std::filesystem::perm_options::nofollow` may not be
        honored on old devices.
      * [Issue 1260]: `std::filesystem:canonical` will incorrectly succeed when
        passed a non-existent path on old devices.

* [Issue 843]: `llvm-strip` is now used instead of `strip` to avoid breaking
   RelRO with LLD. Note that the Android Gradle Plugin performs its own
   stripping, so most users will need to upgrade to Android Gradle Plugin
   version 4.0 or newer to get the fix.

* [Issue 929]: `find_library` now prefers shared libraries from the sysroot over
  static libraries.

* [Issue 1130]: Fixed undefined references to new that could occur when building
  for APIs prior to 21 and the static libc++. Note that LLD appears to have been
  unaffected, but the problem is still present for ndk-build when using the
  deprecated linkers.

* [Issue 1139]: `native_app_glue` now hooks up the `APP_CMD_WINDOW_RESIZED`,
  `APP_CMD_WINDOW_REDRAW_NEEDED`, and `APP_CMD_CONTENT_RECT_CHANGED` messages.

* [Issue 1196]: Backtraces for crashes on devices older than API 29 are now
  correct when using LLD if using ndk-build or the CMake toolchain file. If
  using a different system and targeting devices older than API 29, use
  `-Wl,--no-rosegment` when linking. See the [Build System Maintainers Guide]
  for more information.

* The deprecated `<NDK>/platforms` and `<NDK>/sysroot` directories have been
  removed. These directories were merged and relocated into the toolchain during
  r19. The location of these contents should not be relevant to anyone,
  including build systems, since the toolchain handles them implicitly. If you
  are using a build system that hasn't adapted to the changes introduced in NDK
  r19, file a bug with your build system maintainer. See the [Build System
  Maintainers Guide] for information on using the NDK in your own build system.

* `llvm-ar` is now used instead of `ar`.

* [Issue 1200]: Fixed an issue with using `dlclose` with libraries using
  `thread_local` with non-trivial destructors and the static libc++.

* The legacy libc++ linker scripts in `<NDK>/sources/cxx-stl/llvm-libc++` have
  been removed. The linkers scripts in the toolchain should be used instead as
  described by the [Build System Maintainers Guide].

* LLD is now used by default. If your build is not yet compatible with LLD, you
  can continue using the deprecated linkers, set `APP_LD=deprecated` for
  ndk-build, `ANDROID_LD=deprecated` for CMake, or use an explicit
  `-fuse-ld=gold` or `-fuse-ld=bfd` in your custom build system. If you
  encounter issues be sure to file a bug, because this will not be an option in
  a subsequent release.

  Note that [Issue 843] will affect builds using LLD with binutils strip and
  objcopy as opposed to llvm-strip and llvm-objcopy.

* ndk-gdb now uses lldb as the debugger. gdb is deprecated and will be removed in
  a future release. To fall back to gdb, use --no-lldb option. But please
  [file a bug] explaining why you couldn't use lldb.

[Build System Maintainers Guide]: https://android.googlesource.com/platform/ndk/+/master/docs/BuildSystemMaintainers.md
[Issue 609]: https://github.com/android/ndk/issues/609
[Issue 829]: https://github.com/android/ndk/issues/829
[Issue 929]: https://github.com/android/ndk/issues/929
[Issue 1139]: https://github.com/android/ndk/issues/1139
[Issue 1149]: https://github.com/android/ndk/issues/1149
[Issue 1196]: https://github.com/android/ndk/issues/1196
[Issue 1200]: https://github.com/android/ndk/issues/1200
[Issue 1212]: https://github.com/android/ndk/issues/1212
[Issue 1248]: https://github.com/android/ndk/issues/1248
[Issue 1258]: https://github.com/android/ndk/issues/1258
[Issue 1260]: https://github.com/android/ndk/issues/1260
[Issue 1303]: https://github.com/android/ndk/issues/1303
[file a bug]: https://github.com/android/ndk/issues/new/choose

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
