SUMMARY = "Quectel Connect Manager (quectel-CM)"
DESCRIPTION = "Userspace dialer for Quectel WWAN modules (QMI/MBIM/ATC). \
Used by platform-api cellular connect on NE503 + EM05."
HOMEPAGE = "https://github.com/Carton32/quectel-CM"
# Upstream NOTICE: Quectel provides sources as public-domain for customers.
LICENSE = "PD"
LIC_FILES_CHKSUM = "file://NOTICE;md5=baaf014f63902ecfc26c4e32a06c4622"

# Carton32 mirrors Quectel QConnectManager_Linux V1.6.8 (includes mbim-cm / QMI).
SRC_URI = "git://github.com/Carton32/quectel-CM.git;protocol=https;branch=master"
SRCREV = "b3659fa205e223f8525eb8550ba95e12ec8bfb34"

S = "${WORKDIR}/git"

# busybox provides udhcpc used by quectel-CM's default DHCP path.
RDEPENDS:${PN} = "busybox"

do_compile() {
    oe_runmake release CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS} -lpthread -ldl -lrt"
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/quectel-CM ${D}${bindir}/quectel-CM
    install -m 0755 ${S}/quectel-mbim-proxy ${D}${bindir}/quectel-mbim-proxy
    install -m 0755 ${S}/quectel-qmi-proxy ${D}${bindir}/quectel-qmi-proxy
    install -m 0755 ${S}/quectel-atc-proxy ${D}${bindir}/quectel-atc-proxy

    if [ -f ${S}/default.script ]; then
        install -d ${D}${datadir}/udhcpc
        install -m 0755 ${S}/default.script ${D}${datadir}/udhcpc/default.script.quectel
    fi
}

FILES:${PN} += "${datadir}/udhcpc"
