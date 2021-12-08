Android Clang/LLVM Toolchain
============================

For the latest version of this doc, please make sure to visit:
[Android Clang/LLVM Toolchain Readme Doc](https://android.googlesource.com/toolchain/llvm_android/+/master/README.md)

You can also visit the
[Android Clang/LLVM Prebuilts Readme Doc](https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/master/README.md)
for more information about our prebuilt toolchains (and what versions they are based upon).

Build Instructions
------------------

```
$ mkdir llvm-toolchain && cd llvm-toolchain
$ repo init -u https://android.googlesource.com/platform/manifest -b llvm-toolchain
$ repo sync -c
$ python toolchain/llvm_android/build.py
```

If building on Linux, pass `--no-build windows` to `build.py` to skip
building Clang for Windows.

If you have an additional llvm tree built and present in your `$PATH`, then
`build.py` might fail during the Windows build of libcxxabi with the error
`'libstdc++ version must be at least 4.8.'`. The solution is to remove that
path from your `$PATH` before invoking `build.py`.


Instructions to rebuild a particular toolchain release
------------------------------------------------------

To rebuild a particular toolchain, find the manifest file for that release:

```
$ $TOOLCHAIN_DIR/bin/clang -v
Android (6317467 based on r365631c1) clang version 9.0.8...
```

The build number for that toolchain is `6317467` and the manifest is found in
`$TOOLCHAIN_DIR/manifest_6317467.xml`

Rebuild the toolchain with that manifest:

```
$ mkdir llvm-toolchain && cd llvm-toolchain
$ repo init -u https://android.googlesource.com/platform/manifest -b llvm-toolchain
$ cp $TOOLCHAIN_DIR/manifest_6317467.xml .repo/manifests
$ repo init -m manifest_6317467.xml
$ repo sync -c

# Optional: Apply any LLVM/Clang modifications to toolchain/llvm-project

$ python toolchain/llvm_android/build.py
```

Compiler Update Steps
---------------------

### Step 1: Update source code

1. Download source code.

We can use either llvm-toolchain or master-plus-llvm branch. master-plus-llvm branch is a
combination of llvm-toolchain and aosp-master, which can test building platform and create the
build switch CL in the same tree. llvm-toolchain is more suitable when trying to reproduce a
toolchain from a different release.

```sh
$ mkdir master-plus-llvm && cd master-plus-llvm
$ repo init -u https://android.googlesource.com/platform/manifest -b master-plus-llvm
$ repo sync -c
```

2. Update toolchain/llvm-project.

```sh
# replace r407598 with the update version
$ export NEW_REVISION=r407598
$ cd toolchain/llvm_android
$ ./merge_from_upstream.py --rev $NEW_REVISION
```

3. Update build version.

In android_version.py:
    _patch_level = '1'
    _svn_revision = $NEW_REVISION

4. Test build.

```sh
$ ./build.py
```

5. Submit CLs in toolchain/llvm_android and toolchain/llvm-project together.

Examples are in aosp/1515350 and aosp/1515697.


### Step 2. Update profdata

It is to speed up compile time for the new compiler.
The profdata is generated in [go/ab/aosp-master-plus-llvm](https://ci.android.com/builds/branches/aosp-master-plus-llvm/grid),
target Clang-PGO.

An example is in [aosp/1513058](https://android-review.googlesource.com/c/platform/prebuilts/clang/host/linux-x86/+/1513058/).


### Step 3: Cherry pick patches

Use cherrypick_cl.py to cherry pick upstream patches:
```sh
$ ./cherrypick_cl.py --sha <upstream_patch1_sha> <upstream_patch2_sha> ... --verify-merge --create-cl
```

We want to find all patches before $NEW_REVISION but reverted after $NEW_REVISION in upstream.
Search "revert-checker/android" emails to find candidates, and cherry pick them.

We may revert upstream patches locally or add local patches. Put patch files in patches/, and add
patch info at the end of patches/PATCHES.json.

An example is in [aosp/1556717](https://android-review.googlesource.com/c/toolchain/llvm_android/+/1556717/).


### Step 4: Generate prebuilts

Clang prebuilts are generated in [go/ab/aosp-llvm-toolchain](https://ci.android.com/builds/branches/aosp-llvm-toolchain/grid).
Use update-prebuilts.py to download them.

```sh
$ ./update-prebuilts.py <build_number from aosp-llvm-toolchain>
```

Then upload clang prebuilts in prebuilts/clang/host/linux-x86, prebuilts/clang/host/darwin-x86, and
prebuilts/clang/host/windows-x86 for testing.

An example is in [aosp/1532505](https://android-review.googlesource.com/c/platform/prebuilts/clang/host/linux-x86/+/1532505/).


### Step 5: Test prebuilts

1. Upload switch CL in build/soong.

In build/soong/cc/config/global.go:
	ClangDefaultVersion      = "clang-$NEW_VERSION"
	ClangDefaultShortVersion = "<NEW_CLANG_MAJOR_VERSION>.0.1"

If ther are new compiler warnings we need to suppress, add them at the end of
ClangExtraNoOverrideCflags in build/soong/cc/config/clang.go.

If there are new sanitizer flags we need to suppress, add them in build/soong/cc/sanitize.go.

An example is in [aosp/1541244](https://android-review.googlesource.com/c/platform/build/soong/+/1541244/).

2. Put clang linux-x86 prebuilt CL and soong CL in the same topic. Run presubmit check.

3. Cherry pick the prebuilt and soong CLs to internal main, and run presubmit check. Some tests
(like bionic fortify tests) only run there.

4. Use toolchain/llvm_android/test/scripts/test_prebuilts.py.

```sh
$ test/scripts/test_prebuilts.py --prebuilt_cl <linux-x86 cl no> --soong_cl <soong cl no> \
   --tag "test_clang_${NEW_VERSION}_v1" --test_kind platform --build <build_number of prebuilts> \
   --verbose
```

The test results are shown in go/forrest.
After all tests complete. Run `test/scripts/update_results.py` to upload results to
go/android-llvm-testing-dashboard.

Some device_boot_health_check tests are flaky. So it is unlikely to get fully green results.

5. Manually test on linux.

Below tests have been affected by compiler updates. It's better to test them manually on all
architectures (arm, arm64, x86, x86_64).
    bionic_unit_tests or CtsBionicTestCases
    CtsNNAPITestCases
    CtsMediaV2TestCases

6. Manually test on windows.

Run on wine using test/platform/run_windows_tests.sh.

7. Manually test on darwin.

We used to build platform on darwin. But probably we will change to only build and run selected
tests.


### Step 6: Submit prebuilts

Currently we submit prebuilts before the soong CL. This usually needs the soong CL to wait for
at least six hours to pass presubmit check. Maybe we can submit them together if that is supported
by RBE.


### Step 7: Switch to the new compiler

All places need to switch to the new compiler are listed in
https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/master/README.md.

The updates in the kernel and NDK are done separately.

After switching, we also need to update the doc.


More Information
----------------

We have a public mailing list that you can subscribe to:
[android-llvm@googlegroups.com](https://groups.google.com/forum/#!forum/android-llvm)

