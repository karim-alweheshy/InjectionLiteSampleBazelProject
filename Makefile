update-swift-package-manager:
	@echo "Updating Swift Package Manager..."
	@rm -f tools/snoozel/third_party/swiftpkg/*/{dump,desc}.json tools/snoozel/third_party/swiftpkg/{dump,desc}.json
	@swift package resolve
	@VERBOSE_BAZEL_TOOLS=0 bazel \
		mod \
		--ui_event_filters=-info,-warning,-debug \
		show_extension \
		@rules_swift_package_manager//:extensions.bzl%swift_deps \
		2>/dev/null \
		| perl -ne ' \
			if (/^Fetched repositories:/) { $$in = 1; next } \
			if ($$in && /^\s*-\s*(\S+)(.*)/) { \
				$$repo = $$1; $$rest = $$2; \
				if ($$rest =~ /\(imported by <root>\)/) { \
					print "--repo=\@$$repo\n"; \
				} else { \
					print "--repo=\@\@rules_swift_package_manager++swift_deps+$$repo\n"; \
				} \
			} elsif ($$in && !/^\s*-\s/) { \
				last; \
			}' \
		| VERBOSE_BAZEL_TOOLS=0 xargs bazel \
			fetch \
			--ui_event_filters=-info,-warning,-debug \
			--force
	@VERBOSE_BAZEL_TOOLS=0 bazel \
		mod \
		--ui_event_filters=-info,-warning,-debug \
		deps \
		--lockfile_mode=update
