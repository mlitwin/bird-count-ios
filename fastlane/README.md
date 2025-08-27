fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios generate

```sh
[bundle exec] fastlane ios generate
```

Generate Xcode project via XcodeGen

### ios build_sim

```sh
[bundle exec] fastlane ios build_sim
```

Build app for iOS simulator (Debug)

### ios test_all

```sh
[bundle exec] fastlane ios test_all
```

Run unit tests (macOS core + iOS)

### ios archive

```sh
[bundle exec] fastlane ios archive
```

Archive iOS app (Release)

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight (Release)

### ios codesign_auto

```sh
[bundle exec] fastlane ios codesign_auto
```

Enable Automatic Signing for project (set DEVELOPMENT_TEAM_ID env var)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
