FILESEXTRAPATHS:prepend := "${THISDIR}:"

SRC_URI:append = " file://0001-libhailort-set-stable-soname.patch"

SO_MAJOR_VERSION = "${@d.getVar('PV').split('.')[0]}"

do_install:append() {
    rm -f ${D}${libdir}/libhailort.so
    ln -s -r ${D}${libdir}/libhailort.so.${PV} ${D}${libdir}/libhailort.so.${SO_MAJOR_VERSION}
    ln -s -r ${D}${libdir}/libhailort.so.${SO_MAJOR_VERSION} ${D}${libdir}/libhailort.so
}

FILES:${PN}:append = " ${libdir}/libhailort.so.${SO_MAJOR_VERSION}"
