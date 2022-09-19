#
# Container Image OpenSSH
#

.PHONY: container-run-linux
container-run-linux:
	$(BIN_DOCKER) container create \
		--platform "$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)" \
		--name "sshd" \
		-h "sshd" \
		-u "0" \
		--entrypoint "/usr/local/sbin/sshd" \
		--net "$(NET_NAME)" \
		-p "2222":"22" \
		--health-interval "10s" \
		--health-timeout "8s" \
		--health-retries "3" \
		--health-cmd "sshd-healthcheck \"22\" \"8\"" \
		"$(IMG_REG_URL)/$(IMG_REPO):$(IMG_TAG_PFX)-$(PROJ_PLATFORM_OS)-$(PROJ_PLATFORM_ARCH)" \
		-D \
		-e \
		-f "/usr/local/etc/ssh/sshd_config"
	$(BIN_FIND) "bin" -mindepth "1" -type "f" -iname "*" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "sshd":"/usr/local"
	$(BIN_FIND) "etc/ssh" -mindepth "1" -type "f" -iname "*" ! -iname "ssh_host_*_key" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "sshd":"/usr/local"
	$(BIN_FIND) "etc/ssh" -mindepth "1" -type "f" -iname "ssh_host_*_key" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" --mode "600" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "sshd":"/usr/local"
	$(BIN_FIND) "root/.ssh" -mindepth "1" -type "f" -iname "*" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "sshd":"/"
	$(BIN_DOCKER) container start -a "sshd"

.PHONY: container-run
container-run:
	$(MAKE) "container-run-$(PROJ_PLATFORM_OS)"

.PHONY: container-rm
container-rm:
	$(BIN_DOCKER) container rm -f "sshd"
