# DylibKit

An on-device iOS IPA inspection and dylib integration starter for authorized testing in TrollStore-compatible workflows.

Compatibility varies by app, iOS version, architecture, signing state, entitlements, and dependencies. Universal IPA injection is not guaranteed.

## Current status
- SwiftUI interface to select an IPA and a dylib.
- Basic preflight report UI.
- XcodeGen project definition and GitHub Actions build workflow.
- Mach-O rewriting, load-command editing, entitlement handling, injection, and re-signing are not implemented yet.

Only modify applications you own or are authorized to test.
