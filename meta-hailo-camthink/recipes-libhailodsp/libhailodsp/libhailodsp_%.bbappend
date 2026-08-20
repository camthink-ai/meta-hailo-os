FILESEXTRAPATHS:prepend := "${THISDIR}:"

SRC_URI:append = " file://0001-libhailodsp-set-stable-soname.patch"

# The upstream recipe keeps the unversioned linker-name symlink in ${PN}
# because libhailodsp used to install only libhailodsp.so. After patching the
# CMake project to emit a versioned shared library, restore the conventional
# split: runtime gets libhailodsp.so.* and -dev gets libhailodsp.so.
FILES:${PN}:remove = "${libdir}/libhailodsp.so"
