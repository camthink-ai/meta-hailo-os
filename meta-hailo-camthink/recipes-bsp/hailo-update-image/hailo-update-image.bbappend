# Distinguish deploy SWU names by rootfs flavor (avoids core/dev clobbering
# the same hailo-update-image-${MACHINE}.swu symlink):
#   core-image-hailo-dev → hailo-update-image-dev-${MACHINE}.swu
#   core-image-hailo     → hailo-update-image-core-${MACHINE}.swu
IMAGE_BASENAME = "hailo-update-image-${@bb.utils.contains('HAILO_TARGET', 'core-image-hailo-dev', 'dev', 'core', d)}"

# Hailo15-NE503: rootfs on mmcblk1
SWUPDATE_DEFAULT_FILESYSTEM_DEVICE:hailo15-ne503 = "mmcblk1"

# Override sw-description for hailo15-ne503 (single mode gets a data partition)
FILESEXTRAPATHS:prepend:hailo15-ne503 := "${THISDIR}/files:"
SRC_URI:append:hailo15-ne503 = " file://aipc-require-current-root.sh"

# Validate the exact WORKDIR copy that do_swuimage is about to archive. This
# catches a forced/incremental build accidentally reusing the superseded
# application-owned compatibility writer contract.
python aipc_validate_current_root_contract() {
    import os

    src_uri = d.getVar("SRC_URI") or ""
    if "aipc-require-current-root.sh" not in src_uri:
        return

    path = os.path.join(d.getVar("WORKDIR"), "aipc-require-current-root.sh")
    try:
        with open(path, "r", encoding="utf-8") as stream:
            content = stream.read()
    except OSError as exc:
        bb.fatal("AIPC SWU preinstall contract is unavailable at %s: %s" % (path, exc))

    forbidden = ("aipc-os-release-lib.sh", "missing compatibility writer")
    stale = [value for value in forbidden if value in content]
    if stale:
        bb.fatal("Refusing to package stale AIPC SWU preinstall contract %s: %s" %
                 (path, ", ".join(stale)))

    required = ("aipc-install-current-root.sh", "aipc-compat-check")
    missing = [value for value in required if value not in content]
    if missing:
        bb.fatal("AIPC SWU preinstall contract %s is missing: %s" %
                 (path, ", ".join(missing)))
}

do_swuimage[prefuncs] += "aipc_validate_current_root_contract"

# Build timestamp embedded into sw-description for the ne503 osupgrade validator
# (AIPC_OS_REQUIRE_BUILD_TIME; see ne503 platform/osupgrade/validate.go). ${DATETIME}
# expands to YYYYMMDDHHMMSS, a format validBuildTime accepts. Substituted into
# sw-description via the SWUpdate class @@VAR@@ path (same as @@MACHINE@@, @@HAILO_TARGET@@).
AIPC_BUILD_TIME = "${DATETIME}"
