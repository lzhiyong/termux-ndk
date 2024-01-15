# Advice for Middleware Vendors

Distributing middleware built with the NDK imposes some additional problems that
app developers do not need to worry about. Prebuilt libraries impose some of
their implementation choices on their users.

## Choosing API levels and NDK versions

Your users cannot use a `minSdkVersion` lower than yours. If your users' apps
need to run on Android 16, you cannot build for Android 21.

NDK versions are largely compatible with each other, but occasionally there are
changes that break compatibility. If you know that all of your users are using
the same version of the NDK, it's best to use the same version that they do.
Otherwise, use the newest version.

## Using the STL

If you're writing C++ and using the STL, your choice between libc++_shared and
libc++_static affects your users if you distribute a shared library. If you
distribute a shared library, you must either use libc++_shared or ensure that
libc++'s symbols are not exposed by your library. The best way to do this is to
explicitly declare your ABI surface with a version script (this also helps keep
your implementation details private). For example, a simple arithmetic library
might have the following version script:

Note: If you distribute a static library, it does not matter whether you choose
a static or shared STL because nothing is linked in a static library. The user
can link whichever they choose in their application. They must link *something*,
even for C-only consumers, so be sure to document that it is required and which
version of the NDK was used to build in case of incompatibility in STL versions.

```txt
LIBMYMATH {
global:
    add;
    sub;
    mul;
    div;
    # C++ symbols in an extern block will be mangled automatically. See
    # https://stackoverflow.com/a/21845178/632035 for more examples.
    extern "C++" {
        "pow(int, int)";
    }
local:
    *;
};
```

A version script should be the preferred option because it is the most robust
way to control symbol visibility. Another, less robust option is to use
`-Wl,--exclude-libs,libc++_static.a -Wl,--exclude-libs,libc++abi.a` when
linking. This is less robust because it will only hide the symbols in the
libraries that are explicitly named, and no diagnostics are reported for
libraries that are not used (a typo in the library name is not an error, and the
burden is on the user to keep the library list up to date).

## For Java Middleware with JNI Libraries

Java libraries that include JNI libraries (i.e. use `jniLibs`) need to be
careful that the JNI libraries they include will not collide with other
libraries in the user's app. For example, if the AAR includes
`libc++_shared.so`, but a different version of `libc++_shared.so` than the app
uses, only one will be installed to the APK and that may lead to unreliable
behavior.

Warning: [Bug 141758241]: The Android Gradle Plugin does not currently diagnose
this error condition. One of the identically named libraries will be arbitrarily
chosen for packaging in the APK.

[Bug 141758241]: https://issuetracker.google.com/141758241

The most reliable solution is for Java libraries to include no more than **one**
JNI library. All dependencies including the STL should be statically linked into
the implementation library, and a version script should be used to enforce the
ABI surface. For example, a Java library com.example.foo that includes the JNI
library libfooimpl.so should use the following version script:

```txt
LIBFOOIMPL {
global:
    JNI_OnLoad;
local:
    *;
};
```

Note that this example uses `registerNatives` via `JNI_OnLoad` as described in
[JNI Tips] to ensure that the minimal ABI surface is exposed and library load
time is minimized.

[JNI Tips]: https://developer.android.com/training/articles/perf-jni#native-libraries
