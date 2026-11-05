FILESEXTRAPATHS:prepend:hailo15-ne503 := "${THISDIR}/files:"

UBOOT_BOARD_DTS:hailo15-ne503 = "${MACHINE}.dts"

SRC_URI:append:hailo15-ne503 = " \
    file://0001-hailo15-ne503-board-support.patch \
    file://0002-hailo15-ne503-fixup-linux-memory-reg.patch \
    file://0003-hailo15-ne503-spiflash-gd25lq64c-support.patch \
    file://0004-bootmenu-ignore-serial-noise-during-autoboot.patch \
    file://0005-hailo15-ne503-sdio0-max-frequency-25mhz.patch \
    file://0006-hailo15-print-assembled-dram-pn.patch \
"

def camthink_ddr_dtsi_for_profile(d, profile):
    """Resolve DDR_DTSI:<profile> without changing the active MACHINEOVERRIDES."""
    localdata = d.createCopy()
    # Rightmost override wins; append so this profile beats active DDR_PROFILE.
    localdata.appendVar('OVERRIDES', ':%s' % profile)
    dtsi = localdata.getVar('DDR_DTSI')
    if not dtsi:
        bb.fatal('No DDR_DTSI mapping for profile %s' % profile)
    return dtsi

def camthink_parse_ddr_variants(d):
    """Return list of (alias, profile, dtsi) from DDR_UBOOT_VARIANTS."""
    variants = []
    for item in (d.getVar('DDR_UBOOT_VARIANTS') or '').split():
        if ':' not in item:
            bb.fatal('DDR_UBOOT_VARIANTS entry must be alias:profile, got: %s' % item)
        alias, profile = item.split(':', 1)
        variants.append((alias, profile, camthink_ddr_dtsi_for_profile(d, profile)))
    return variants

def camthink_register_ddr_patch(d, dtsidir, dtsi):
    """Register matching *_patch.dtsi in hailo15_ddr_patch_include.dtsi if needed."""
    import os

    if not dtsi.endswith('.dtsi'):
        return

    base_dtsi = dtsi.replace('-f1.dtsi', '.dtsi')
    patch_dtsi = base_dtsi[:-5] + '_patch.dtsi'
    if not os.path.isfile(os.path.join(dtsidir, patch_dtsi)):
        bb.warn('DDR patch dtsi not found for %s: %s' % (dtsi, patch_dtsi))
        return

    patch_include = os.path.join(dtsidir, 'hailo15_ddr_patch_include.dtsi')
    if not os.path.isfile(patch_include):
        bb.fatal('hailo15_ddr_patch_include.dtsi not found: %s' % patch_include)

    with open(patch_include, 'r', encoding='utf-8') as f:
        patch_content = f.read()
    if patch_dtsi in patch_content:
        return

    if not patch_content.endswith('\n'):
        patch_content += '\n'
    with open(patch_include, 'w', encoding='utf-8') as f:
        f.write(patch_content + '#include "%s"\n' % patch_dtsi)
    bb.note('Registered DDR patch dtsi: %s' % patch_dtsi)

# Inject DDR_DTSI from DDR_PROFILE into hailo15-ne503.dts, emit alias DTS
# variants for one-shot multi-DDR signed DTB deploy, and register patches.
python do_patch:append:hailo15-ne503() {
    import os
    import re
    import shutil

    dts = d.getVar('UBOOT_BOARD_DTS')
    dtsi = d.getVar('DDR_DTSI')
    if not dts or not dtsi:
        return

    srcdir = d.getVar('S')
    workdir = d.getVar('WORKDIR')
    dtsidir = os.path.join(srcdir, 'arch', 'arm', 'dts')
    path = os.path.join(dtsidir, dts)
    if not os.path.isfile(path):
        bb.fatal('UBOOT_BOARD_DTS not found: %s' % path)

    bb.note('DDR profile %s: %s -> %s' % (d.getVar('DDR_PROFILE'), dtsi, dts))

    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    def with_ddr_include(text, ddr_dtsi):
        return re.sub(
            r'#include "hailo1x_ddr_[^"]*\.dtsi"',
            '#include "%s"' % ddr_dtsi,
            text,
        )

    primary = with_ddr_include(content, dtsi)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(primary)

    # Install camthink custom selection dtsi when present.
    src = os.path.join(workdir, dtsi)
    if os.path.isfile(src):
        shutil.copy2(src, os.path.join(dtsidir, dtsi))
        bb.note('Installed custom DDR dtsi: %s' % dtsi)

    camthink_register_ddr_patch(d, dtsidir, dtsi)

    variants = camthink_parse_ddr_variants(d)
    if not variants:
        return

    makefile = os.path.join(dtsidir, 'Makefile')
    with open(makefile, 'r', encoding='utf-8') as f:
        mk = f.read()

    basestem = os.path.splitext(dts)[0]
    # Drop any prior variant lines (including ones wrongly appended after targets +=).
    mk = re.sub(
        r'^dtb-\$\(CONFIG_TARGET_HAILO15_NE503\) \+= %s-[A-Za-z0-9_]+\.dtb\n' % re.escape(basestem),
        '',
        mk,
        flags=re.M,
    )

    # Must insert before "targets += $(dtb-y)" or the extra DTBs are ignored.
    anchor = 'dtb-$(CONFIG_TARGET_HAILO15_NE503) += %s.dtb' % basestem
    if anchor not in mk:
        bb.fatal('Could not find Makefile anchor for %s' % basestem)

    extra_lines = []
    for alias, profile, vdtsi in variants:
        vname = '%s-%s.dts' % (basestem, alias)
        vpath = os.path.join(dtsidir, vname)
        with open(vpath, 'w', encoding='utf-8') as f:
            f.write(with_ddr_include(content, vdtsi))
        bb.note('DDR variant %s (%s): %s -> %s' % (alias, profile, vdtsi, vname))

        vsrc = os.path.join(workdir, vdtsi)
        if os.path.isfile(vsrc):
            shutil.copy2(vsrc, os.path.join(dtsidir, vdtsi))

        camthink_register_ddr_patch(d, dtsidir, vdtsi)
        extra_lines.append(
            'dtb-$(CONFIG_TARGET_HAILO15_NE503) += %s-%s.dtb' % (basestem, alias)
        )

    if extra_lines:
        mk = mk.replace(anchor, anchor + '\n' + '\n'.join(extra_lines))
        with open(makefile, 'w', encoding='utf-8') as f:
            f.write(mk)
}

# Build/sign alias DTBs after BSP signs the primary u-boot.dtb.
do_compile:append:hailo15-ne503() {
    basestem="$(basename "${UBOOT_BOARD_DTS}" .dts)"
    for item in ${DDR_UBOOT_VARIANTS}; do
        alias="${item%%:*}"
        dtb="${B}/arch/arm/dts/${basestem}-${alias}.dtb"
        if [ ! -f "${dtb}" ]; then
            oe_runmake -C "${S}" O="${B}" "arch/arm/dts/${basestem}-${alias}.dtb"
        fi
        if [ ! -f "${dtb}" ]; then
            bbfatal "DDR variant DTB missing: ${dtb}"
        fi
        fdt_add_pubkey -a "${FIT_HASH_ALG},${FIT_SIGN_ALG}" -k "${UBOOT_SIGN_KEYDIR}" \
            -n ${UBOOT_SIGN_KEYNAME} -r conf "${dtb}"
        hailo15_boot_image_sign "${dtb}" ${HAILO_SOC_NAME} devicetree \
            "${B}/${basestem}-${alias}.dtb.signed"
    done
}

do_deploy:append:hailo15-ne503() {
    basestem="$(basename "${UBOOT_BOARD_DTS}" .dts)"
    for item in ${DDR_UBOOT_VARIANTS}; do
        alias="${item%%:*}"
        signed="${B}/${basestem}-${alias}.dtb.signed"
        if [ ! -f "${signed}" ]; then
            bbfatal "Signed DDR variant DTB missing: ${signed}"
        fi
        install -m 0644 "${signed}" \
            "${DEPLOYDIR}/u-boot-${UBOOT_DDR_DTB_TAG}-${alias}.dtb.signed"
    done
}
