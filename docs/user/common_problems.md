# Common Problems and Solutions

This document lists common issues that users encounter when using the NDK. It is
by no means complete, but represents some of the most common non-bugs we see
filed.


## Using `_FILE_OFFSET_BITS=64` With Early API Levels

Prior to [Unified Headers], the NDK did not support `_FILE_OFFSET_BITS=64`. If
you defined it when building, it was silently ignored. With [Unified Headers]
the `_FILE_OFFSET_BITS=64` option is now supported, but on old versions of
Android very few of the `off_t` APIs were available as an `off64_t` variant, so
using this feature with old API levels will result in fewer functions being
available.

This problem is explained in detail in the [r16 blog post] and in the [bionic
documentation].

[Unified Headers]: ../UnifiedHeaders.md
[r16 blog post]: https://android-developers.googleblog.com/2017/09/introducing-android-native-development.html
[bionic documentation]: https://android.googlesource.com/platform/bionic/+/master/docs/32-bit-abi.md

**Problem**: Your build is asking for APIs that do not exist in your
`minSdkVersion`.

**Solution**: Disable `_FILE_OFFSET_BITS=64` or raise your `minSdkVersion`.

### Undeclared or implicit definition of `mmap`

In C++:

> error: use of undeclared identifier 'mmap'

In C:

> warning: implicit declaration of function 'mmap' is invalid in C99

Using `_FILE_OFFSET_BITS=64` instructs the C library to use `mmap64` instead of
`mmap`. `mmap64` was not available until android-21. If your `minSdkVersion`
value is lower than 21, the C library does not contain an `mmap` that is
compatible with `_FILE_OFFSET_BITS=64`, so the function is unavailable.

**Note**: `mmap` is only the most common manifestation of this problem. The same
is true of any function in the C library that has an `off_t` parameter.

**Note**: As of r16 beta 2, the C library exposes `mmap64` as an inline function
to mitigate this instance of this issue.

TODO: Update this section once we know what the next most common problem is.


## Target API Set Higher Than Device API

The target API level in the NDK has a very different meaning than
`targetSdkVersion` does in Java. The NDK target API level is your app's
**minimum** supported API level. In ndk-build, this is your `APP_PLATFORM`
setting.

Since references to functions are (typically) resolved when a library is
loaded rather than when they are first called, you cannot reference APIs that
are not always present and guard their use with API level checks. If they are
referred to at all, they must be present.

**Problem**: Your target API level is higher than the API supported by your
device.

**Solution**: Set your target API level (`APP_PLATFORM`) to the minimum version
of Android your app supports.

Build System         | Setting
---------------------|-------------------
ndk-build            | `APP_PLATFORM`
CMake                | `ANDROID_PLATFORM`
Standalone Toolchain | `--api`
Gradle               | TODO: No idea

### Cannot Locate `__aeabi` Symbols

> UnsatisfiedLinkError: dlopen failed: cannot locate symbol "`__aeabi_memcpy`"

Note that these are *runtime* errors. These errors will appear in the log when
you attempt to load your native libraries. The symbol might be any of
`__aeabi_*` (`__aeabi_memcpy` and `__aeabi_memclr` seem to be the most common).

This problem is documented at https://github.com/android-ndk/ndk/issues/126.

### Cannot Locate Symbol `rand`

> UnsatisfiedLinkError: dlopen failed: cannot locate symbol "`rand`"

This problem was explained very well on Stack Overflow:
http://stackoverflow.com/a/27338365/632035

There are a handful of other symbols that are also affected by this.
TODO: Figure out what the other ones were.


## Undefined Reference to `__atomic_*`

**Problem**: Some ABIs (particularly armeabi) need libatomic to provide some
implementations for atomic operations.

**Solution**: Add `-latomic` when linking.

> error: undefined reference to '`__atomic_exchange_4`'

The actual symbol here might be anything prefixed with `__atomic_`.

Note that ndk-build, cmake, and libc++ standalone toolchains handle this for
you. For non libc++ standalone toolchains or a different build system, you may
need to do this manually.


## RTTI/Exceptions Not Working Across Library Boundaries

**Problem**: Exceptions are not being caught when thrown across shared library
boundaries, or `dynamic_cast` is failing.

**Solution**: Add a [key function] to your types. A key function is the first
non-pure, out-of-line virtual function for a type. For an example, see the
discussion on [Issue 533].

The [C++ ABI] states that two objects have the same type if and only if their
`type_info` pointers are identical. Exceptions may only be caught if the
`type_info` for the catch matches the thrown exception. The same rule applies
for `dynamic_cast`.

When a type does not have a key function, its typeinfo is emitted as a weak
symbol and matching type infos are merged when libraries are loaded. When
loading libraries dynamically after the executable has been loaded (i.e. via
`dlopen` or `System.loadLibrary`), it may not be possible for the loader to
merge type infos for the loaded libraries. When this happens, the two types are
not considered equal.

Note that for non-polymorphic types, the type cannot have a key function. For
non-polymorphic types, RTTI is unnecessary, as `std::is_same` can be used to
determine type equality at compile time.

[C++ ABI]: https://itanium-cxx-abi.github.io/cxx-abi/abi.html#rtti
[Issue 533]: https://github.com/android-ndk/ndk/issues/533#issuecomment-335977747
[key function]: https://itanium-cxx-abi.github.io/cxx-abi/abi.html#vague-vtable


## Using Mismatched Prebuilt Libraries

Using prebuilt libraries (third-party libraries, typically) in your application
requires a bit of extra care. In general, the following rules need to be
followed:

* The resulting app's minimum API level is the maximum of all API levels
  targeted by all libraries.

  If your target API level is android-9, but you're using a prebuilt library
  that was built against android-16, the resulting app's minimum API level is
  android-16.  Failure to adhere to this will be visible at build time if the
  prebuilt library is static, but may not appear until run time for prebuilt
  shared libraries.

* All libraries should be generated with the same NDK version.

  This rule is a bit more flexible than most, but in general NDK code is only
  guaranteed to be compatible with code generated with the same version of the
  NDK (minor revision mismatches generally okay).

* All libraries must use the same STL.

  A library using libc++ will not interoperate with one using stlport. All
  libraries in an application must use the same STL.

  Strictly speaking this can be made to work, but it's a very fragile
  configuration. Avoid it.

* Apps with multiple shared libraries must use a shared STL.

  https://developer.android.com/ndk/guides/cpp-support.html#sr

  As with mismatched STLs, the problems caused by this can be avoided if great
  care is taken, but it's better to just avoid the problem.
