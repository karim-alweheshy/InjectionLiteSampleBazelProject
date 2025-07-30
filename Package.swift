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
      url: "https://github.com/karim-alweheshy/InjectionLite",
      revision: "dc8647b754e78aa274e522e5838114b854cc7ac3"
    ),
  ]
)
