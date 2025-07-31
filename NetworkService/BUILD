load("@rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "NetworkService",
    srcs = [
        "NetworkServiceView.swift",
        "MockAPIService.swift",
        "NetworkModels.swift",
        "NetworkServiceViewController.swift",
    ],
    deps = [
        "@swiftpkg_inject//:Inject",
        "//DataAnalytics:DataAnalytics",
    ],
    module_name = "NetworkService",
    visibility = ["//visibility:public"],
)