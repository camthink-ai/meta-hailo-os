SUMMARY = "CamThink custom rootfs overlay (scripts and files)"
DESCRIPTION = "Installs board/product files from files/overlay/ into the image \
rootfs. Drop scripts or config under files/overlay/ using the destination \
path layout (e.g. usr/local/bin/foo.sh -> /usr/local/bin/foo.sh)."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Overlay tree is optional until content is added.
SRC_URI = "file://overlay/"

S = "${WORKDIR}"

# Runtime helpers used by overlay scripts (already on AIPC images via packagegroup).
RDEPENDS:${PN} += "libgpiod-tools"

# Allow an empty package while the overlay is still being filled in.
ALLOW_EMPTY:${PN} = "1"

do_install() {
    if [ ! -d "${WORKDIR}/overlay" ]; then
        bbnote "camthink-rootfs: no overlay/ content; installing empty package"
        return 0
    fi

    install -d ${D}
    # Copy overlay tree; do not keep host uid/gid (cp -a would contaminate
    # do_package with getpwuid KeyError for uid 1000).
    cp -a --no-preserve=ownership ${WORKDIR}/overlay/. ${D}/

    # Scaffold / editor keep files must not land on the device.
    find ${D} -name '.keep' -delete 2>/dev/null || true

    # Ensure pseudo records root ownership for packaging.
    chown -R root:root ${D}

    # Scripts under standard bin dirs default to executable.
    for d in \
        ${D}${base_bindir} \
        ${D}${base_sbindir} \
        ${D}${bindir} \
        ${D}${sbindir} \
        ${D}${libexecdir} \
        ${D}/usr/local/bin \
        ${D}/usr/local/sbin; do
        if [ -d "$d" ]; then
            find "$d" -type f -exec chmod 0755 {} +
        fi
    done
}

# Only ship what the overlay actually installs (avoid packaging bare /).
FILES:${PN} += "/usr /etc /opt /lib /bin /sbin /var /home /data"
