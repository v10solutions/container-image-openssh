#
# Container Image OpenSSH
#

.PHONY: img-reg-login
img-reg-login:
	$(BIN_DOCKER) login \
		-u "$(IMG_REG_USR)" \
		-p "$(IMG_REG_PWD)" \
		"$(IMG_REG_URL)"

.PHONY: img-build
img-build:
	mkdir -p ".output/img/$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)"
	$(BIN_DOCKER) buildx build \
		-f "img-$(PROJ_PLATFORM_OS).dockerfile" \
		--pull \
		--force-rm \
		--progress "plain" \
		--platform "$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)" \
		--build-arg PROJ_NAME="$(PROJ_NAME)" \
		--build-arg PROJ_VERSION="$(PROJ_VERSION)" \
		--build-arg PROJ_BUILD_NUM="$(PROJ_BUILD_NUM)" \
		--build-arg PROJ_BUILD_DATE="$(PROJ_BUILD_DATE)" \
		--build-arg PROJ_REPO="$(PROJ_REPO)" \
		-t "$(IMG_REG_URL)/$(IMG_REPO):$(IMG_TAG_PFX)-$(PROJ_PLATFORM_OS)-$(PROJ_PLATFORM_ARCH)" \
		-o type="docker",dest=".output/img/$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)/$(PROJ_NAME)_$(PROJ_BUILD_NUM)_$(PROJ_PLATFORM_OS)_$(PROJ_PLATFORM_ARCH).tar.gz" \
		"."

.PHONY: img-rm
img-rm:
	rm -r -f ".output/img/$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)"
	$(BIN_DOCKER) image rm "$(IMG_REG_URL)/$(IMG_REPO):$(IMG_TAG_PFX)-$(PROJ_PLATFORM_OS)-$(PROJ_PLATFORM_ARCH)"

.PHONY: img-load
img-load:
	$(BIN_DOCKER) image load -i ".output/img/$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)/$(PROJ_NAME)_$(PROJ_BUILD_NUM)_$(PROJ_PLATFORM_OS)_$(PROJ_PLATFORM_ARCH).tar.gz"

.PHONY: img-push
img-push:
	$(BIN_DOCKER) image push "$(IMG_REG_URL)/$(IMG_REPO):$(IMG_TAG_PFX)-$(PROJ_PLATFORM_OS)-$(PROJ_PLATFORM_ARCH)"

.PHONY: img-pull
img-pull:
	$(BIN_DOCKER) image pull "$(IMG_REG_URL)/$(IMG_REPO):$(IMG_TAG_PFX)-$(PROJ_PLATFORM_OS)-$(PROJ_PLATFORM_ARCH)"
