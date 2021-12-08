# Clang Migration Notes

The Android OS switched to clang several years ago. Future versions of
the NDK will remove GCC, so the sooner you start testing your project
with clang the better!

## How to switch to clang

For `ndk-build`, remove lines setting `NDK_TOOLCHAIN` or
`NDK_TOOLCHAIN_VERSION`.

For cmake, remove lines setting `ANDROID_TOOLCHAIN`.

For standalone toolchains, use the `clang`/`clang++` binaries instead of
`gcc`/`g++`.

For other build systems, ask the owners of that build system.

## How to fix common problems

When moving to Clang from GCC, you may notice some differences.

### `-Oz` versus `-Os`

[Clang Optimization Flags](https://clang.llvm.org/docs/CommandGuide/clang.html#code-generation-options)
has the full details, but if you used `-Os` to optimize your
code for size with GCC, you probably want `-Oz` when using
Clang. Although `-Os` attempts to make code small, it still
enables some optimizations that will increase code size (based on
https://stackoverflow.com/a/15548189/632035). For the smallest possible
code with Clang, prefer `-Oz`. With `-Oz`, Chromium actually saw both
size *and* performance improvements when moving to Clang compared to
`-Os` with GCC.

### `__attribute__((__aligned__))`

Normally the `__aligned__` attribute is given an explicit alignment,
but with no value means “maximum alignment”. The interpretation of
“maximum” differs between GCC and Clang: Clang includes vector types
too so for ARM GCC thinks the maximum alignment is 8 (for `uint64_t`), but
Clang thinks it’s 16 (because there are NEON instructions that require
16-byte alignment). Normally this shouldn’t matter because malloc is
always at least 16-byte aligned, and mmap regions are page (4096-byte)
aligned. Most code should either specify an explicit alignment or use
[alignas](http://en.cppreference.com/w/cpp/language/alignas) instead.

### `-Bsymbolic`

When targeting Android (but no other platform), GCC passed
[-Bsymbolic](ftp://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_node/ld_3.html)
to the linker by default. This is not a good default, so Clang does not
do that. `-Bsymbolic` causes the following behavior change:

```c++
// foo.cpp
#include <iostream>

void foo() {
  std::cout << "Goodbye, world" << std::endl;
}

void bar() {
  foo();
}
```

```c++
// main.cpp
#include <iostream>

extern void bar();

void foo() {
  std::cout << "Hello, world\n";
}

int main(int, char**) {
  foo(); // Prints “Hello, world!”
  bar(); // Without -Bsymbolic, prints “Hello, world!” With -Bsymbolic, prints “Goodbye, world!”
}
```

In addition to not being the "expected" default behavior on all other
platforms, this prevents symbol interposition (used by tools such
as asan).

You might however wish to add manually `-Bsymbolic` back because it can
result in smaller ELF files because fewer relocations are needed. If you
do want the non-`-Bsymbolic` behavior but would like fewer relocations,
that can be achieved via `-fvisibility=hidden` (and manually exporting
the symbols you want to be public, using the `JNI_EXPORT` macro in JNI
code or `__attribute__ ((visibility("default")))` otherwise. Linker
version scripts are an even more powerful mechanism for controlling
exported symbols, but harder to use.

### `-fno-integrated-as`

Especially for ARM and ARM64, Clang is much stricter about assembler
rules than GCC/GAS. Use `-fno-integrated-as` if Clang reports errors in
inline assembly or assembly files that you don't wish to modernize.
