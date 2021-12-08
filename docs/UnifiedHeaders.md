# Unified Headers

[Issue #120](https://github.com/android-ndk/ndk/issues/120)

Before NDK r14, we had a set of libc headers for each API version. In many cases
these headers were incorrect. Many exposed APIs that didn't exist, and others
didn't expose APIs that did.

In NDK r14 (as an opt in feature) we unified these into a single set of headers,
called unified headers. This single header path is used for *every* platform
level. API level guards are handled with `#ifdef`. These headers can be found in
[prebuilts/ndk/platform/sysroot].

Unified headers are built directly from the Android platform, so they are up to
date and correct (or at the very least, any bugs in the NDK headers will also be
a bug in the platform headers, which means we're much more likely to find them).

In r15 unified headers are used by default. In r16, the old headers have been
removed.

[prebuilts/ndk/headers]: https://android.googlesource.com/platform/prebuilts/ndk/+/dev/platform/sysroot/usr/include

## Supporting Unified Headers in Your Build System

See the [Build System Maintainers] doc.

[Build System Maintainers]: BuildSystemMaintainers.md
