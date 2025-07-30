# InjectionLite Sample Bazel Project

This project demonstrates how to build an iOS SwiftUI application using Bazel with InjectionLite integration for hot reloading during development.

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

## Building the Project

### 1. Clone and Navigate to the Project
```bash
cd InjectionLiteSampleBazelProject
```

### 2. Update Swift Package Dependencies
```bash
make update-swift-package-manager
```

### 3. Build the iOS Application
```bash
bazel build //:InjectionLiteSampleBazelProjectApp
```

### 4. Run on iOS Simulator
```bash
bazel run //:InjectionLiteSampleBazelProjectApp
```

## Project Structure

- `BUILD` - Bazel build configuration defining iOS app target
- `MODULE.bazel` - Bazel module configuration with dependencies
- `Package.swift` - Swift Package Manager configuration for InjectionLite
- `InjectionLiteSampleBazelProject/` - Source code directory
  - `InjectionLiteSampleBazelProjectApp.swift` - Main app entry point
  - `ContentView.swift` - SwiftUI view with InjectionLite integration
  - `Info.plist` - iOS app configuration

## InjectionLite Integration

This project includes InjectionLite for hot reloading:

- **Linker flags**: `-interposable` flag is configured in the BUILD file
- **Dependencies**: InjectionLite is imported from the Swift package
- **Usage**: Simply save any Swift file while running in debug mode to see changes

## Development Workflow

1. Build and run the app: `bazel run //:InjectionLiteSampleBazelProjectApp`
2. Make changes to Swift files (e.g., `ContentView.swift`)
3. Save the file - InjectionLite will automatically reload the changes
4. See your changes reflected in the running app without restart

## Troubleshooting

### Build Issues
- Ensure Xcode Command Line Tools are installed: `xcode-select --install`
- Clean Bazel cache: `bazel clean --expunge`
- Update dependencies: `make update-swift-package-manager`

### Simulator Issues
- Make sure you have iOS Simulator installed with Xcode
- Check available simulators: `xcrun simctl list devices`

### InjectionLite Not Working
- Ensure you're running in debug mode
- Check that the `-interposable` linker flag is present in BUILD file
- InjectionLite works best in iOS Simulator, not on physical devices

## Customization

To modify this sample for your own project:

1. Update the `bundle_id` in `BUILD` file
2. Change the `name` in `MODULE.bazel`
3. Update Swift package dependencies in `Package.swift`
4. Modify source files in the `InjectionLiteSampleBazelProject/` directory

## Additional Resources

- [Bazel Documentation](https://bazel.build/)
- [rules_apple Documentation](https://github.com/bazelbuild/rules_apple)
- [InjectionLite GitHub](https://github.com/johnno1962/InjectionLite)