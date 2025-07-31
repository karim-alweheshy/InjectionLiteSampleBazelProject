load("@rules_swift//mixed_language:mixed_language_library.bzl", "mixed_language_library")

mixed_language_library(
    name = "DataAnalytics",
    clang_srcs = [
        "DataProcessor.m",
    ], 
    swift_srcs = [
        "AnalyticsView.swift",
        "ChartData.swift",
        "AnalyticsViewController.swift",
    ],
    hdrs = [
        "DataProcessor.h",
    ],
    deps = [
        "@swiftpkg_inject//:Inject",
    ],
    module_name = "DataAnalytics",
    visibility = ["//visibility:public"],
)