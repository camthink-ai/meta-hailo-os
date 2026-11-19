SUMMARY = "Quectel QLog modem diagnostic capture tool"
DESCRIPTION = "Userspace tool to capture Quectel WWAN DM logs (qmdl) for NE503."
HOMEPAGE = "https://github.com/quectel-official/QLog"
SECTION = "connectivity"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=9a8969c0259d4069c5e82b81662988b2"

# sahara-ramdump.h includes <libudev.h> (header only; systemd/eudev PROVIDES udev).
DEPENDS = "udev"

SRC_URI = "git://github.com/quectel-official/QLog.git;protocol=https;branch=main"
SRCREV = "81527baf70345aabf02402f4961e368034a92258"

PV = "1.5.18+git${SRCPV}"
S = "${WORKDIR}/git"

do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} \
        -Wall -O1 -Wno-error=unused-but-set-variable \
        -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE \
        main.c mdm.c tty2tcp.c tftp.c usb_linux.c ftp.c sahara-ramdump.c sahara-xprt.c \
        -o qlog -lpthread -ldl -lrt
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/qlog ${D}${bindir}/qlog

    if [ -d ${S}/conf ]; then
        install -d ${D}${datadir}/qlog/conf
        install -m 0644 ${S}/conf/*.cfg ${D}${datadir}/qlog/conf/
    fi
}

FILES:${PN} += "${datadir}/qlog"
