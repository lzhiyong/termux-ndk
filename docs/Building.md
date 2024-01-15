# Building the NDK

The latest version of this document is available at
https://android.googlesource.com/platform/ndk/+/master/docs/Building.md.

Both Linux and Windows NDKs are built on Linux machines. Windows host binaries
are cross-compiled with MinGW.

Building the NDK for Mac OS X requires at least 10.9.

## Prerequisites

* [AOSP NDK Repository](http://source.android.com/source/downloading.html)
    * Check out the branch `master-ndk`

        ```bash
        repo init -u https://android.googlesource.com/platform/manifest \
            -b master-ndk

        # Googlers, use
        repo init -u \
            persistent-https://android.git.corp.google.com/platform/manifest \
            -b master-ndk
        ```

If you wish to rebuild a given release of the NDK, the release branches can also
be checked out. They're named `ndk-release-r${RELEASE}` for newer releases, but
`ndk-r{RELEASE}-release` for older releases. For example, to check out the r19
release branch, use the `-b ndk-release-r19` flag instad of `-b master-ndk`.

Linux dependencies are listed in the [Dockerfile]. You can use docker to build
the NDK:

```bash
docker build -t ndk-dev infra/docker
docker run -it -u $UID -v `realpath ..`:/src -w /src/ndk ndk-dev ./checkbuild.py
```

Building on Mac OS X has similar dependencies as Linux, but also requires Xcode.

Running tests requires that `adb` is in your `PATH`. This is provided as part of
the [Android SDK].

[Dockerfile]: ../infra/docker/Dockerfile
[Android SDK]: https://developer.android.com/studio/index.html#downloads

## Building the NDK

### For Linux or Darwin:

```bash
$ python checkbuild.py
```

### For Windows, from Linux:

```bash
$ python checkbuild.py --system windows64  # Or "windows", for a 32-bit host.
```

`checkbuild.py` will also build all of the NDK tests. This takes about as long
as building the NDK itself, so pass `--no-build-tests` to skip building the
tests. They can be built later with `python run_tests.py --rebuild`.

Note: The NDK's build and test scripts are implemented in Python 3 (currently
3.6). `checkbuild.py` will bootstrap by building Python 3.6 from source before
running, but `run_tests.py` does not do this yet. `run_tests.py` also can be run
outside of a complete development environment (as it is when it is run on
Windows), so a Python 3.6 virtualenv is recommended.

## Packaging

By default, `checkbuild.py` will also package the NDK. To skip the packaging
step, use the `--no-package` flag. To avoid packaging an incomplete NDK,
packaging will not be run if `--module` was passed unless `--force-package` was
also provided.
