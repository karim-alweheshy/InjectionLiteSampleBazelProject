// swift-tools-version: 6.0.0
//
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// After changing this file, add the the repo name to `use_repo` in
// `MODULE.bazel` and run `make update-swift-package-manager`.
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

import PackageDescription

let package = Package(
  name: "injection-lite",
  dependencies: [
    // HotReloading 1.4.0RC3
    .package(
      url: "https://github.com/johnno1962/InjectionNext",
      revision: "e87a5e89da6c31c5e590b1ad489008a104c17677"
    ),
    .package(
        url: "https://github.com/krzysztofzablocki/Inject",
        from: "1.2.4"
    )
  ]
)
