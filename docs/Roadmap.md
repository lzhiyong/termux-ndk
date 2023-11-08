# NDK Roadmap

**Note**: If there's anything you want to see done in the NDK, [file a bug]!
Nothing here is set in stone, and if there's something that we haven't thought
of that would be of more use, we'd be happy to adjust our plans for that.

[file a bug]: https://github.com/android-ndk/ndk/issues

**Disclaimer**: Everything here is subject to change. The further the plans are
in the future, the less stable they will be. Things in the upcoming release are
fairly certain, and the second release is quite likely. Beyond that, anything
written here is what we would like to accomplish in that release assuming things
have gone according to plan until then.

**Note**: For release timing, see our [release schedule] on our wiki.

[release schedule]: https://github.com/android-ndk/ndk/wiki#release-schedule

---

## Regular maintenance

Every NDK release aims to include a new toolchain, new headers, and a new
version of libc++.

We also maintain [GitHub Projects](https://github.com/android/ndk/projects)
to track the bugs we intend to fix in any given NDK release.

### Toolchain updates

The NDK and the Android OS use the same toolchain. Android's toolchain team is
constantly working on updating to the latest upstream LLVM for the OS. It can
take a long time to investigate issues when compiling -- or issues that the
newer compiler finds in -- OS code or OEM code, for all 4 supported
architectures, so these updates usually take a few months.

Even then, a new OS toolchain may not be good enough for the NDK. In the OS, we
can work around compiler bugs by changing our code, but for the NDK we want to
make compiler updates cause as little disruption as possible. We also don't want
to perform a full compiler update late in the NDK release cycle for the sake of
stability.

The aim is that each NDK will have a new toolchain that's as up to date as
feasible without sacrificing stability, but we err on the side of stability when
we have to make a choice. If an NDK release doesn't include a new compiler, or
that compiler isn't as new as you'd hoped, trust us --- you wouldn't want
anything newer that we have just yet!

## Current work

Most of the team's work is currently focused outside the NDK proper, so while
the NDK release notes may seem a bit sparse, there are still plenty of
improvements coming for NDK users:

* Improving NDK and Android Gradle Plugin documentation.
* Improving the OS (in particular the linker).
* Getting an up to date LLDB for Android Studio. We'll be adding LLDB support to
  ndk-gdb after this is done.
* Working with the Android frameworks teams to get new NDK APIs.
* Improving the workflow and tooling for supporting Android preview releases so
  we don't lose so much time to them in the future.

### NDK r22

#### C++ File System API

[Issue 609](https://github.com/android-ndk/ndk/issues/609)

libc++'s `std::filesystem` is now ported and included in the NDK.

#### Default to LLD and LLVM binutils

NDK r18 [made LLD available](https://github.com/android-ndk/ndk/issues/683),
r20 made it more usable, and r22 has made it the default.

r22 also migrates from GNU `ar` and `strip` to `llvm-ar` and `llvm-strip`. No
GNU binutils tools are used by the NDK with the default configuration. GNU
binutils will be removed in a future release of the NDK.

#### lldb debugger

LLDB is now included alongside the toolchain in the NDK, and `ndk-gdb` supports
the `--lldb` option. GDB will be removed in a future release of the NDK.

## Future work

The following projects are listed in order of their current priority.

Note that some of these projects do not actually affect the contents of the NDK
package. The samples, documentation, etc are all NDK work but are separate from
the NDK package. As such they will not appear in any specific release, but are
noted here to show where the team's time is being spent.

### Migrate remaining architectures to LLVM's unwinder

[Issue 1230]: https://github.com/android/ndk/issues/1230

Right now only 32-bit Arm uses the LLVM unwinder for exception handling, and the
remaining architectures rely on libgcc. Using the same unwinder across all
architectures will give more predictable behavior, and consolidating on a single
unwinder reduces duplicated upkeep costs so we can work on other improvements.

### Migrate from libgcc to libclang_rt

[Issue 1231]: https://github.com/android/ndk/issues/1231

These two libraries provide the runtime support the compiler relies on. While
similar, LLVM's `libclang_rt.builtins` includes many things that libgcc does
not. We've been working around inconsistencies for a while by using both, but it
would be best to just finish the migration.

One blocker here is that most architectures currently rely on libgcc for
exception handling support. Once we've migrated to LLVM's unwinder for all
architectures this will be easier.

### Remove GNU binutils

We've switched to LLD and the rest of the LLVM tools by default as of r22. We
should consolidate on the supported tools after they have been given some soak
time to discover and fix any remaining issues.

### CMake

CMake added their own NDK support about the same time we added our
toolchain file. The two often conflict with each other, and a toolchain
file is a messy way to implement this support. However, fully switching to
the integrated support puts NDK policy decisions (default options, NDK layout,
etc) fully into the hands of CMake, which makes them impossible to update
without the user also updating their CMake version.

We will reorganize our toolchain file to match the typical implementation of a
CMake platform integration (like `$CMAKE/Modules/Platform/Android-*.cmake`) and
CMake will be modified to load the implementation from the NDK rather than its
own.

Preferably, most of this work will actually involve improving Clang's defaults
so that the toolchain file doesn't need to do anything aside from setting up
toolchain paths.

See [Issue 463](https://github.com/android-ndk/ndk/issues/463) for discussion.

---

## Unscheduled Work

The following projects are things we intend to do, but have not yet been
scheduled into the sections above.

### Better documentation

We should probably add basic doc comments to the bionic headers:

* One-sentence summary.
* One paragraph listing any Android differences. (Perhaps worth upstreaming this
  to man7.org too.)
* Explain any "flags" arguments (at least giving some idea of which flags)?
* Explain the return value: what does a `char*` point to? Who owns it? Are
  errors -1 (as for most functions) or `<errno.h>` values (for
  `pthread_mutex_lock`)?
* A "See also" pointing to man7.org?

Should these be in the NDK API reference too? If so, how will we keep
them from swamping the "real" NDK API?

vim is ready, Android Studio now supports doxygen comments (but seems
to have gained a new man page viewer that takes precedence),
and Visual Studio Code has nothing but feature requests.

Beyond writing the documentation, we also should invest some time in improving
the presentation of the NDK API reference on developer.android.com.

### Better samples

The samples are low-quality and don't necessarily cover interesting/difficult
topics.

### Better tools for improving code quality

The NDK has long included `gtest` and clang supports various sanitiziers,
but there are things we can do to improve the state of testing/code quality:

* Test coverage support.
* Add `gmock`.
* Make [GTestJNI] available to developers via Maven so developers can integrate
  their C++ tests into Studio.

[GTestJNI]: https://github.com/danalbert/GTestJNI

### C++ wrappers for NDK APIs

NDK APIs are C-only for ABI stability reasons.

We should offer C++ wrappers as part of an NDK support library (possibly as part
of JetPack), even if only to offer the benefits of RAII.  Examples include
[Bitmap](https://github.com/android-ndk/ndk/issues/822),
[ATrace](https://github.com/android-ndk/ndk/issues/821), and
[ASharedMemory](https://github.com/android-ndk/ndk/issues/820).

### JNI helpers

Complaints about basic JNI handling are common. We should make libnativehelper
available as an AAR.

### Improve automation in ndkports so we can take on more packages

Before we can take on maintenance for additional packages we need to improve the
tooling for ndkports. Automation for package updates, testing, and the release
process would make it possible to expand.

### NDK icu4c wrapper

For serious i18n, `icu4c` is too big too bundle, and non-trivial to use
the platform. We have a C API wrapper prototype, but we need to make it
easily available for NDK users.

### More automated libc++ updates

We still need to update libc++ twice: once for the platform, and once
for the NDK. We also still have two separate test runners.

### Weak symbols for API additions

iOS developers are used to using weak symbols to refer to function that
may be present in their equivalent of `targetSdkVersion` but not in their
`minSdkVersion`. We could potentially do something similar. See
[issue 1003](https://github.com/android-ndk/ndk/issues/1003).

### C++ Modules

By Q2 2019 Clang may have a complete enough implementation of the modules TS and
Android may have a Clang with those changes available.

At least for the current spec (which is in the process of merging with the Clang
implementation, so could change), the NDK will need to:

 1. Support compiling module interfaces.
 2. Support either automated discovery (currently very messy) or specification
    of module dependencies.
 3. Begin creating module interfaces for system libraries. Frameworks, libc,
    libc++, etc.

---

## Historical releases

Full [history] is available, but this section summarizes major changes
in recent releases.

[history]: https://developer.android.com/ndk/downloads/revision_history.html

### Package management

We shipped [Prefab] and the accompanying support for the Android Gradle Plugin
to support native dependencies. AGP 4.0 includes the support for importing these
packages, and 4.1 includes the support for creating AARs that support them.

We also maintain a few packages as part of [ndkports]. Currently just curl,
OpenSSL, and JsonCpp.

[Prefab]: https://github.com/google/prefab
[ndkports]: https://android.googlesource.com/platform/tools/ndkports/

### NDK r21 LTS

Updated Clang, LLD, libc++, make, and GDB. Much better LLD behavior on Windows.
32-bit Windows support removed. Neon by default for all API levels. OpenMP now
available as both a static and shared library.

### NDK r20

Updated Clang and libc++, added Q APIs. Improved out-of-the-box Clang behavior.

### NDK r19

Reorganized the toolchain packaging and modified Clang so that standalone
toolchains are now unnecessary. Clang can now be invoked directly from its
installed location in the NDK.

C++ compilation defaults to C++14.

### NDK r18

Removed GCC and gnustl/stlport. Added lld.

Added `compile_commands.json` for better tooling support.

### NDK r17

Defaulted to libc++.

Removed ARMv5 (armeabi), MIPS, and MIPS64.

### NDK r16

Fixed libandroid\_support, libc++ now the recommended STL (but still
not the default).

Removed non-unified headers.

### NDK r15

Defaulted to [unified headers] (opt-out).

Removed support for API levels lower than 14 (Android 4.0).

### NDK r14

Added [unified headers] (opt-in).

[unified headers]: https://android.googlesource.com/platform/ndk/+/master/docs/UnifiedHeaders.md

### NDK r13

Added [simpleperf].

[simpleperf]: https://developer.android.com/ndk/guides/simpleperf.html

### NDK r12

Removed [armeabi-v7a-hard].

Removed support for API levels lower than 9 (Android 2.3).

[armeabi-v7a-hard]: https://android.googlesource.com/platform/ndk/+/ndk-r12-release/docs/HardFloatAbi.md
