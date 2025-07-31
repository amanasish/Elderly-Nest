# Elder Nest – macOS Setup Log

## ✅ 1. Homebrew Installation

* Installed Homebrew using the official script.
* Confirmed working with: `brew --version`
* Added Homebrew to PATH using:

  ```bash
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ```
* Verified size with:

  ```bash
  du -sh /opt/homebrew
  ```

## ✅ 2. Flutter Setup

* Installed Flutter SDK manually.
* Added Flutter to PATH via `.zprofile` or `.zshrc` using `nano`:

  ```bash
  export PATH="$PATH:[your-flutter-path]/flutter/bin"
  ```
* Verified with: `flutter doctor`

## ✅ 3. VS Code Extensions Installed

* Flutter
* Dart
* Pubspec Assist

## ✅ 4. Notes

* Avoided `Editor: Mouse Wheel Zoom` as it zooms the full VS Code UI.
* Set `Editor: Font Size` manually instead for code-only zoom.
