FILESEXTRAPATHS:prepend:hailo15-ne503 := "${THISDIR}/files:"

UBOOT_BOARD_DTS:hailo15-ne503 = "${MACHINE}.dts"

SRC_URI:append:hailo15-ne503 = " \
    file://0001-hailo15-ne503-board-support.patch \
    file://0002-hailo15-ne503-fixup-linux-memory-reg.patch \
    file://0003-hailo15-ne503-spiflash-gd25lq64c-support.patch \
    file://0004-bootmenu-ignore-serial-noise-during-autoboot.patch \
    file://0005-hailo15-ne503-sdio0-max-frequency-25mhz.patch \
"

# Inject DDR_DTSI from DDR_PROFILE into hailo15-ne503.dts.
# Install camthink selection dtsi and register matching *_patch.dtsi if missing.
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

    content = re.sub(
        r'#include "hailo1x_ddr_[^"]*\.dtsi"',
        '#include "%s"' % dtsi,
        content,
    )

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

    # Install camthink custom selection dtsi when present.
    src = os.path.join(workdir, dtsi)
    if os.path.isfile(src):
        shutil.copy2(src, os.path.join(dtsidir, dtsi))
        bb.note('Installed custom DDR dtsi: %s' % dtsi)

    if not dtsi.endswith('.dtsi'):
        return

    # Register matching *_patch.dtsi if missing from hailo15_ddr_patch_include.dtsi.
    # Selection files named *-f1.dtsi reuse the base PN patch (strip -f1).
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
    if patch_dtsi not in patch_content:
        if not patch_content.endswith('\n'):
            patch_content += '\n'
        with open(patch_include, 'w', encoding='utf-8') as f:
            f.write(patch_content + '#include "%s"\n' % patch_dtsi)
        bb.note('Registered DDR patch dtsi: %s' % patch_dtsi)
}
