Updating Documentation
======================

The documentation in [docs/user](user) is a subset of the guides that are
present on the [developer website]. It will some day be all the guides, but
we're doing this piece by piece.

[developer website]: https://developer.android.com/ndk/guides/index.html

To update the documentation, edit the appropriate Markdown file. For
https://developer.android.com/ndk/guides/StandaloneToolchain.html, edit
[docs/user/StandaloneToolchain.md](user/StandaloneToolchain.md). The page layout
is handled by [docs/user/dac\_template.jd](user/dac_template.jd), but that
should not be altered unless the layout of DAC is changed.

The docs are not automatically pushed to the website. A Googler will need to run
`scripts/update_dac.py` to publish changes. Googlers: simply run this script
with the path to the root of your docs tree as the argument, make the commit,
and upload the patch.
