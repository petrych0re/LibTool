# LibTool

**LibTool** is a native SwiftUI utility for inspecting IPA/ZIP packages for common Unity game markers. It is designed as a lightweight package-inspection aid for iOS developers and jailbreak researchers.

## Features

- Import an IPA or ZIP using the iOS document picker.
- Inspect archive entry names for common Unity indicators.
- Show detected markers and the selected archive name.
- Dark SwiftUI interface.
- GitHub Actions build on macOS; the workflow packages an unsigned device-build IPA as an artifact.

## Unity markers

The scanner checks archive paths for markers such as `UnityFramework.framework`, `Unity-iPhone`, `Data/Managed`, `globalgamemanagers`, and `libil2cpp`.

Detection is heuristic. A missing marker does **not** prove a game is not made with Unity. The app inspects only the archive selected by the user; it does not automatically enumerate installed apps or bypass another app's sandbox.

## Build locally

1. Install Xcode 15 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen).
2. Clone this repository.
3. Run `xcodegen generate`.
4. Open `LibTool.xcodeproj` in Xcode, or build from the command line.

The GitHub Actions workflow runs on a macOS runner and uploads `LibTool-unsigned.ipa` as a downloadable artifact. TrollStore compatibility and installation must be tested on the target device; the artifact is not App Store-signed.

## Tech stack

- Swift 5
- SwiftUI
- ZIPFoundation
- XcodeGen
- GitHub Actions

## License

MIT. See [LICENSE](LICENSE).
