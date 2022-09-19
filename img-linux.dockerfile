#
# Container Image OpenSSH
#

FROM alpine:3.16.2

ARG PROJ_NAME
ARG PROJ_VERSION
ARG PROJ_BUILD_NUM
ARG PROJ_BUILD_DATE
ARG PROJ_REPO

LABEL org.opencontainers.image.authors="V10 Solutions"
LABEL org.opencontainers.image.title="${PROJ_NAME}"
LABEL org.opencontainers.image.version="${PROJ_VERSION}"
LABEL org.opencontainers.image.revision="${PROJ_BUILD_NUM}"
LABEL org.opencontainers.image.created="${PROJ_BUILD_DATE}"
LABEL org.opencontainers.image.description="Container image for OpenSSH"
LABEL org.opencontainers.image.source="${PROJ_REPO}"

RUN apk update \
	&& apk add --no-cache "shadow" "bash" \
	&& usermod -s "$(command -v "bash")" "root"

SHELL [ \
	"bash", \
	"--noprofile", \
	"--norc", \
	"-o", "errexit", \
	"-o", "nounset", \
	"-o", "pipefail", \
	"-c" \
]

ENV LANG "C.UTF-8"
ENV LC_ALL "${LANG}"
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib/ssh"

RUN apk add --no-cache \
	"ca-certificates" \
	"curl" \
	"ldns-dev" \
	"krb5-dev" \
	"zlib-dev" \
	"utmps-dev" \
	"openssl-dev" \
	"libedit-dev" \
	"linux-pam-dev"

RUN apk add --no-cache -t "build-deps" \
	"make" \
	"patch" \
	"linux-headers" \
	"gcc" \
	"g++" \
	"pkgconf"

RUN groupadd -r -g "480" "ssh" \
	&& useradd \
		-r \
		-m \
		-s "$(command -v "nologin")" \
		-g "ssh" \
		-c "SSH" \
		-u "480" \
		"ssh"

WORKDIR "/tmp"

COPY "patches" "patches"

RUN curl -L -f -o "ssh.tar.gz" "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${PROJ_VERSION}.tar.gz" \
	&& mkdir "ssh" \
	&& tar -x -f "ssh.tar.gz" -C "ssh" --strip-components "1" \
	&& pushd "ssh" \
	&& find "../patches" \
		-mindepth "1" \
		-type "f" \
		-iname "*.patch" \
		-exec bash --noprofile --norc -c "patch -p \"1\" < \"{}\"" ";" \
	&& ./configure \
		--prefix="/usr/local" \
		--libdir="/usr/local/lib/ssh" \
		--libexecdir="/usr/local/libexec/ssh" \
		--sysconfdir="/usr/local/etc/ssh" \
		--datarootdir="/usr/local/share/ssh" \
		--sharedstatedir="/usr/local/com/ssh" \
		--runstatedir="/usr/local/var/run/ssh" \
		--with-pam \
		--with-zlib \
		--with-ldns \
		--with-xauth \
		--with-libedit \
		--with-kerberos5 \
		--with-ssl-engine \
		--with-mantype="man" \
		--with-maildir="/var/mail" \
		--with-default-path="${PATH}" \
		--with-privsep-user="ssh" \
		--with-privsep-path="/var/empty" \
		--with-pid-dir="/usr/local/var/run/ssh" \
		--with-libs="$(pkg-config --libs --static "utmps")" \
		--with-cflags="$(pkg-config --cflags --static "utmps")" \
		--without-rpath \
		--disable-utmp \
		--disable-wtmp \
		--disable-strip \
		--disable-lastlog \
	&& make \
	&& make "install" \
	&& ldconfig "${LD_LIBRARY_PATH}" \
	&& rm -f "/usr/local/etc/ssh/"*"_key"* \
	&& popd \
	&& rm -r -f "ssh" \
	&& rm "ssh.tar.gz" \
	&& rm -r -f "patches"

WORKDIR "/usr/local"

RUN mkdir -p "etc/ssh" "lib/ssh" "libexec/ssh" "share/ssh"  \
	&& folders=("com/ssh" "var/run/ssh") \
	&& for folder in "${folders[@]}"; do \
		mkdir -p "${folder}" \
		&& chmod "700" "${folder}" \
		&& chown -R "0":"0" "${folder}"; \
	done

WORKDIR "/root"

RUN mkdir ".ssh" \
	&& chmod "700" ".ssh" \
	&& touch ".ssh/authorized_keys"

WORKDIR "/"

RUN apk del "build-deps"

STOPSIGNAL "SIGTERM"
