// swift-tools-version: 6.0.2
//
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// After changing this file, add the the repo name to `use_repo` in
// `MODULE.bazel` and run `make update-swift-package-manager`.
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

import PackageDescription

let package = Package(
  name: "injection-lite",
  dependencies: [
    // HotReloading 1.4.0RC1
    .package(
      url: "https://github.com/karim-alweheshy/InjectionNext",
      revision: "0202f9156cd2f165ec6d96a3acdd84441b4766ab"
    ),
    .package(
        url: "https://github.com/krzysztofzablocki/Inject",
        from: "1.2.4"
    )
  ]
)
