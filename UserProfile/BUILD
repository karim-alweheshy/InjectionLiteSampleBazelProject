load("@rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "UserProfile",
    srcs = [
        "UserProfileView.swift",
        "UserProfileModel.swift",
        "UserProfileViewController.swift",
        "EditProfileViewController.swift",
    ],
    deps = [
        "@swiftpkg_inject//:Inject",
    ],
    module_name = "UserProfile",
    visibility = ["//visibility:public"],
)