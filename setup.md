# Elder Nest – Development Environment Setup Log

This file tracks all installations and configurations done for the project.

---

## ✅ \[2025-08-01] Initial Setup

### 1. Installed Homebrew

* Command:

  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

### 2. Installed Flutter SDK

* Downloaded from: [flutter.dev](https://docs.flutter.dev/get-started/install/macos)
* Extracted and renamed to: `flutter_sdk/`
* Added to PATH via `.zshrc`:

  ```bash
  export PATH="$PATH:$HOME/Downloads/Development/flutter_sdk/bin"
  ```

### 3. Installed VS Code Extensions

* Flutter
* Dart
* Pubspec Assist

---

## ✅ \[2025-08-01] Android SDK Setup (Command Line Only)

### 4. Installed Android SDK (No Android Studio)

* Downloaded **command line tools** from:
  [https://developer.android.com/studio#command-tools-only](https://developer.android.com/studio#command-tools-only)
* Extracted and moved to:
  `~/Downloads/Development/android_sdk/cmdline-tools/latest`

### 5. Installed SDK Components

```bash
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
```

### 6. Accepted Licenses

```bash
sdkmanager --licenses
```

### 7. Environment Variables (added to `.zshrc`)

```bash
export ANDROID_HOME=$HOME/Downloads/Development/android_sdk
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH
```

### 8. Flutter Configured for Android SDK

```bash
flutter config --android-sdk $ANDROID_HOME
flutter doctor
```

---

> ✅ You can keep appending future setups below this line. Example:
>
> ## ✅ \[2025-08-03] Firebase Setup (Future)
