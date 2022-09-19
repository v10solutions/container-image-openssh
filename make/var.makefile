#
# Container Image OpenSSH
#

SHELL := bash --noprofile --norc -o errexit -o nounset -o pipefail -c
.SHELLFLAGS :=
MAKEFLAGS += --warn-undefined-variables

export BIN_GH ?= gh
export BIN_GIT ?= git
export BIN_DOCKER ?= docker
ifeq ($(shell uname -s),Linux)
	export BIN_TAR ?= tar
	export BIN_AWK ?= awk
	export BIN_DATE ?= date
	export BIN_FIND ?= find
else
	export BIN_TAR ?= gtar
	export BIN_AWK ?= gawk
	export BIN_DATE ?= gdate
	export BIN_FIND ?= gfind
endif

ifeq ($(shell $(BIN_GIT) status --porcelain 2>&1),)
	export GIT_COMMIT_TIMESTAMP ?= $(shell $(BIN_GIT) log -n "1" --format="%cI")
	export GIT_COMMIT_SHORT_SHA ?= $(shell $(BIN_GIT) log -n "1" --format="%h")
	export GIT_TAG ?= $(shell $(BIN_GIT) describe --exact-match --tags "$(GIT_COMMIT_SHORT_SHA)" 2>"/dev/null")
else
	export GIT_COMMIT_TIMESTAMP ?=
	export GIT_COMMIT_SHORT_SHA ?=
	export GIT_TAG ?=
endif

export PROJ_ID ?=
export PROJ_NAME ?= container-image-openssh
export PROJ_VERSION ?= 9.0p1
export PROJ_BUILD_NUM ?= $(shell BIN_DATE="$(BIN_DATE)" tools/build-num "$(GIT_COMMIT_TIMESTAMP)" "$(GIT_COMMIT_SHORT_SHA)")
export PROJ_BUILD_DATE ?= $(shell $(BIN_DATE) -u -Iseconds)
export PROJ_PLATFORM_OS ?= linux
export PROJ_PLATFORM_ARCH ?= amd64
export PROJ_REPO ?= https://github.com/v10solutions/$(PROJ_NAME)

export BUILDKIT_NAME ?= $(PROJ_NAME)
export BUILDKIT_CFG_FILE ?= buildkit.toml

export IMG_REG_URL ?= docker.io
export IMG_REG_USR ?=
export IMG_REG_PWD ?=
export IMG_REPO ?= v10solutions/$(subst container-image-,,$(PROJ_NAME))
export IMG_TAG_PFX ?= $(PROJ_VERSION)

export NET_NAME ?= bridge

.PHONY: printv-%
printv-%:
	@printf "%s" "$($*)"
