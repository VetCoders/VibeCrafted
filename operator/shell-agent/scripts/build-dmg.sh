#!/usr/bin/env bash
set -eo pipefail

# 5-step pipeline: cargo release builds -> bindings generate -> xcodegen -> xcodebuild Release -> codesign deep + hdiutil UDZO.
# T6 zaimplementuje pełen multi-binary bundle copy do Contents/MacOS/{Vibecrafted, vc-mux-daemon, vc-mux-tray, vc-operator-tui}.
# Bundle ID: io.vetcoders.vibecrafted
# SIGNING_IDENTITY="Developer ID Application: Maciej Gad (MW223P3NPX)"

echo "TODO (T4): implement full dmg build flow in T6"
