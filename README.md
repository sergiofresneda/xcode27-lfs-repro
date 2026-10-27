# Xcode 27 Git LFS Reproduction

Minimal iOS project reproducing Xcode 27 reporting that Git LFS is not
installed when resolving a Swift package that contains an LFS-tracked resource.

The dependency is
[`xcode27-lfs-dependency`](https://github.com/sergiofresneda/xcode27-lfs-dependency),
pinned to `1.0.1`. That tag points to the default branch `HEAD`, keeping this
case separate from the non-HEAD tag bug fixed by SwiftPM #10720.

## Requirements

- Apple silicon Mac
- Xcode 27.2
- Git LFS installed with Homebrew at `/opt/homebrew/bin/git-lfs`
- `git lfs install` already executed

## Reproduction

1. Confirm Git LFS works in Terminal:

   ```sh
   /opt/homebrew/bin/git-lfs version
   git lfs version
   ```

2. Open `LFSReproApp.xcodeproj` from Finder or the Dock-launched Xcode.
3. Select **File > Packages > Reset Package Caches**.
4. Select **File > Packages > Resolve Package Versions**.

### Actual result

SwiftPM reports:

```text
Git LFS is not installed.
Install Git LFS to use packages with large files:
  macOS:   brew install git-lfs && git lfs install
```

### PATH control

Quit Xcode and launch it with Homebrew available in `PATH`:

```sh
env PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
  /Applications/Xcode.app/Contents/MacOS/Xcode LFSReproApp.xcodeproj
```

Reset and resolve packages again. Xcode now finds and invokes `git-lfs`, so the
incorrect `Git LFS is not installed` diagnostic disappears.

With Xcode 27.2, resolution may then expose a separate SwiftPM LFS checkout
failure:

```text
error transferring "...": [0] remote missing object ...
error: external filter '/opt/homebrew/bin/git-lfs filter-process' failed
```

Using the published `1.0.1` dependency containing `pixel.png` (an actual 995 B
PNG), a clean Xcode 27.2 package cache fails while checking out the tag:

```text
Downloading Sources/LFSDependency/Resources/pixel.png (995 B)
Error downloading object: Sources/LFSDependency/Resources/pixel.png (...):
Smudge error: ... remote missing object ...
```

A direct clone of the same `1.0.1` tag materializes the LFS object correctly:

```sh
git clone --branch 1.0.1 \
  https://github.com/sergiofresneda/xcode27-lfs-dependency.git
```

This confirms that the object is present on GitHub. It also keeps the PATH
detection failure distinguishable from SwiftPM's subsequent mirror/checkout
handling.

## Expected result

Xcode should discover the Git LFS installation recommended by its own error
message, or preserve the underlying `git lfs version` error and document how a
GUI-launched Xcode should locate Homebrew tools. Once found, SwiftPM should
materialize the LFS resource just as a direct clone does.
