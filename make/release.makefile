#
# Container Image OpenSSH
#

.PHONY: release-create
release-create:
	$(BIN_FIND) ".output" \
		-mindepth "1" \
		-type "f" \
		-iname "$(PROJ_NAME)_$(PROJ_BUILD_NUM)*" \
		-exec tools/release-create "{}" "+"
