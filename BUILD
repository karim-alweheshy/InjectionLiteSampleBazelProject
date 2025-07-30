load("@rules_swift//swift:swift.bzl", "swift_library")
load("@rules_apple//apple:ios.bzl", "ios_application")
load("@rules_xcodeproj//xcodeproj:defs.bzl", "top_level_target", "xcodeproj")

swift_library(
    name = "InjectionLiteSampleBazelProject",
    srcs = [
        "InjectionLiteSampleBazelProject/InjectionLiteSampleBazelProjectApp.swift",
        "InjectionLiteSampleBazelProject/ContentView.swift",
    ],
    deps = [
        "@swiftpkg_injectionlite//:InjectionLite",
    ],
    module_name = "InjectionLiteSampleBazelProject",
    visibility = ["//visibility:public"],
)

ios_application(
    name = "InjectionLiteSampleBazelProjectApp",
    bundle_id = "com.example.InjectionLiteSampleBazelProject",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = ["InjectionLiteSampleBazelProject/Info.plist"],
    minimum_os_version = "15.0",
    deps = [":InjectionLiteSampleBazelProject"],
    linkopts = [
        "-interposable",
    ],
    visibility = ["//visibility:public"],
)

xcodeproj(
    name = "InjectionLiteSampleProject",
    project_name = "InjectionLiteSampleBazelProject",
    tags = ["manual"],
    top_level_targets = [
        top_level_target(
            ":InjectionLiteSampleBazelProjectApp",
            target_environments = [
                "simulator",
            ],
        ),
    ],
)