#
# Container Image OpenSSH
#

.PHONY: buildx-create
buildx-create:
	$(BIN_DOCKER) buildx create \
		--name "$(BUILDKIT_NAME)" \
		--driver "docker-container" \
		--platform "$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)" \
		--config "${BUILDKIT_CFG_FILE}"

.PHONY: buildx-use
buildx-use:
	$(BIN_DOCKER) buildx use "$(BUILDKIT_NAME)"

.PHONY: buildx-rm
buildx-rm:
	$(BIN_DOCKER) buildx rm "$(BUILDKIT_NAME)"
