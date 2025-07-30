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

## Option 1: Command Line Development

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
2. Make changes to Swift files (e.g., `ContentView.swift`)
3. Save the file - InjectionLite will automatically reload the changes
4. See your changes reflected in the running app without restart

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
5. Save files - InjectionLite will automatically reload changes
6. Changes will be reflected in the running app without restart

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
- `InjectionLiteSampleBazelProject/` - Source code directory
  - `InjectionLiteSampleBazelProjectApp.swift` - Main app entry point
  - `ContentView.swift` - SwiftUI view with InjectionLite integration
  - `Info.plist` - iOS app configuration

## InjectionLite Integration

This project includes InjectionLite for hot reloading:

- **Linker flags**: `-interposable` flag is configured in the BUILD file
- **Dependencies**: InjectionLite is imported from the Swift package
- **Usage**: Simply save any Swift file while running in debug mode to see changes
- **Works with both**: Command line Bazel runs and Xcode project builds

## Troubleshooting

### Build Issues
- Ensure Xcode Command Line Tools are installed: `xcode-select --install`
- Clean Bazel cache: `bazel clean --expunge`
- Update dependencies: `make update-swift-package-manager`

### Xcode Project Generation Issues
- If Xcode project generation fails, try: `bazel clean`
- Regenerate the project: `bazel run //:InjectionLiteSampleProject`
- Make sure rules_xcodeproj is properly configured in MODULE.bazel

### Simulator Issues
- Make sure you have iOS Simulator installed with Xcode
- Check available simulators: `xcrun simctl list devices`

### InjectionLite Not Working
- Ensure you're running in debug mode
- Check that the `-interposable` linker flag is present in BUILD file
- InjectionLite works best in iOS Simulator, not on physical devices
- For Xcode builds, ensure the project was generated with the linker flags

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