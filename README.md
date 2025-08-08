# InjectionLite Sample Bazel Project

This project demonstrates how to build an iOS SwiftUI application using Bazel with InjectionLite integration for hot reloading during development. You can run this project either from the command line using Bazel directly, or generate an Xcode project for development in Xcode.

## Prerequisites

### Install Bazel

1. **Using Homebrew (Recommended):**
   ```bash
   brew install bazel
   ```

2. **Using the Bazel installer:**
   - Download from [Bazel releases](https://github.com/bazelbuild/bazel/releases)
   - Follow the installation instructions for macOS

3. **Verify installation:**
   ```bash
   bazel version
   ```

### Install Xcode and Command Line Tools

1. Install Xcode from the Mac App Store
2. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

## Getting Started

### 1. Clone and Navigate to the Project
```bash
cd InjectionLiteSampleBazelProject
```

### 2. Update Swift Package Dependencies
```bash
make update-swift-package-manager
```

## Option 1: Command Line Development (with InjectionNext)
Note: `bazel build/run` invokes the project wrapper internally; you don't need to call `./tools/bazel` directly.

### Build the iOS Application
```bash
bazel build //:InjectionLiteSampleBazelProjectApp
```

### Run on iOS Simulator
```bash
bazel run //:InjectionLiteSampleBazelProjectApp
```

### Development Workflow (Command Line)
1. Build and run the app: `bazel run //:InjectionLiteSampleBazelProjectApp`
2. The wrapper will auto-launch `tools/injection/InjectionNext.app` if needed and register the workspace for watching
3. Make changes to Swift files (e.g., `ContentView.swift`) and save
4. InjectionLite will hot-reload changes in the running app (simulator)

## Option 2: Xcode Development

### Generate Xcode Project
```bash
bazel run //:InjectionLiteSampleProject
```

This will generate an Xcode project file: `InjectionLiteSampleBazelProject.xcodeproj`

### Open in Xcode
```bash
open InjectionLiteSampleBazelProject.xcodeproj
```

### Development Workflow (Xcode)
1. Open the generated Xcode project
2. Select your target device/simulator in Xcode
3. Build and run using Xcode (⌘+R)
4. Make changes to Swift files directly in Xcode
5. Hot reload is NOT supported when running from Xcode in this project
6. Rebuild to see changes when using Xcode

### Xcode Project Benefits
- Full Xcode IDE features (autocomplete, debugging, etc.)
- Integrated Interface Builder (if using Storyboards)
- Xcode's built-in iOS Simulator management
- Native Xcode debugging experience
- Access to Xcode's profiling tools

## Project Structure

- `BUILD` - Bazel build configuration defining iOS app target and Xcode project generation
- `MODULE.bazel` - Bazel module configuration with dependencies (includes rules_xcodeproj)
- `Package.swift` - Swift Package Manager configuration for InjectionLite
- `tools/bazel` - Bazel wrapper that auto-starts InjectionNext and registers the workspace when running iOS app targets
- `tools/injection/InjectionNext.app` - Bundled InjectionNext app used for hot reload
- `tools/injection/notify-watch.py` - Helper to notify InjectionNext of the project root
- `InjectionLiteSampleBazelProject/` - Source code directory
  - `InjectionLiteSampleBazelProjectApp.swift` - Main app entry point
  - `ContentView.swift` - SwiftUI view with InjectionLite integration
  - `Info.plist` - iOS app configuration

## InjectionLite Integration

This project includes InjectionLite for hot reloading:

- **Linker flags**: `-interposable` flag is configured in the BUILD file
- **Dependencies**: InjectionLite is imported from the Swift package
- **GUI App**: `InjectionNext.app` is bundled at `tools/injection/InjectionNext.app`
- **Auto start**: Using `bazel run` auto-starts InjectionNext (if not running) and registers the workspace for hot reload
- **Usage**: Save any Swift file while running in debug mode to see changes
- **Support**: Hot reload is only supported via command-line `bazel run`; Xcode builds do not support InjectionNext in this project

### Configuration
- **Port**: The wrapper uses port `8887` by default. Override with `INJECTION_PORT`, e.g. `INJECTION_PORT=8888 bazel run //:InjectionLiteSampleBazelProjectApp`.

## Troubleshooting

### Build Issues
- Ensure Xcode Command Line Tools are installed: `xcode-select --install`
- Clean Bazel cache: `bazel clean --expunge`
- Update dependencies: `make update-swift-package-manager`

### Missing Headers or Dependency Issues
If you encounter errors like:
- `undeclared inclusion(s) in rule`
- `missing dependency declarations for the following files`
- Header files not found
- Swift package dependency resolution failures

**Solution:**
```bash
bazel clean --expunge
make update-swift-package-manager
bazel build //:InjectionLiteSampleBazelProjectApp
```

The `--expunge` flag completely removes all build artifacts and cached dependencies, forcing a fresh rebuild that often resolves dependency and header issues.

### Target Exclusion or Visibility Issues
If you see errors about targets not being visible or excluded from builds:
- Add `visibility = ["//visibility:public"]` to your targets in BUILD file
- Run `bazel clean --expunge` to clear any cached visibility rules
- Regenerate dependencies: `make update-swift-package-manager`

### Permission Issues
If you encounter permission errors for reading or writing files:
- Check file permissions: `ls -la`
- Ensure your user has read/write access to the project directory
- Run `bazel clean --expunge` to clear any corrupted cache files
- On macOS, you may need to grant Terminal/IDE access in System Preferences > Security & Privacy

### Xcode Project Generation Issues
- If Xcode project generation fails, try: `bazel clean --expunge`
- Regenerate the project: `bazel run //:InjectionLiteSampleProject`
- Make sure rules_xcodeproj is properly configured in MODULE.bazel

### Simulator Issues
- Make sure you have iOS Simulator installed with Xcode
- Check available simulators: `xcrun simctl list devices`

### InjectionLite Not Working
- Ensure you're running in debug mode
- Check that the `-interposable` linker flag is present in BUILD file
- Prefer iOS Simulator over physical devices
- Hot reload is not supported when running from Xcode; use `bazel run //:InjectionLiteSampleBazelProjectApp`
- If you changed the port, ensure `INJECTION_PORT` matches `notify-watch.py` second arg

### General Recovery Steps
When in doubt, try this sequence:
1. `bazel clean --expunge` - Completely clean all Bazel artifacts
2. `make update-swift-package-manager` - Update Swift package dependencies
3. `bazel build //:InjectionLiteSampleBazelProjectApp` - Rebuild from scratch
4. If using Xcode: `bazel run //:InjectionLiteSampleProject` - Regenerate Xcode project

## Customization

To modify this sample for your own project:

1. Update the `bundle_id` in `BUILD` file
2. Change the `name` in `MODULE.bazel`
3. Update Swift package dependencies in `Package.swift`
4. Modify source files in the `InjectionLiteSampleBazelProject/` directory

## Additional Resources

- [Bazel Documentation](https://bazel.build/)
- [rules_apple Documentation](https://github.com/bazelbuild/rules_apple)
- [rules_xcodeproj Documentation](https://github.com/MobileNativeFoundation/rules_xcodeproj)
- [InjectionLite GitHub](https://github.com/johnno1962/InjectionLite)