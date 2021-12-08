# Continuous Builds

The NDK's continuous builds can be accessed by anyone at
https://ci.android.com/builds/branches/aosp-master-ndk/grid. aosp-master-ndk is
the development branch, and release branches can be selected with the branch
name field at the top of the page.

**Disclaimer**: These builds are **not** suitable for production use. This is
just a continuous build. The amount of testing these builds have been put
through is minimal. A successful build only means that our test suite *built*
successfully on Linux and Darwin. Windows is not covered (the Windows build bots
are actually Linux), and none of the tests have actually been run yet.

## NDK Branches

### NDK Canary

This is the master (development) branch of the NDK. Corresponds to
https://android.googlesource.com/platform/manifest/+/master-ndk.

### NDK rSOMETHING Release

Release branches of the NDK. You can find the build number for the official
release by examining the source.properties file in your NDK. The `Pkg.Revision`
entry is in the format MAJOR.MINOR.BUILD (with beta information being appended
if appropriate).
