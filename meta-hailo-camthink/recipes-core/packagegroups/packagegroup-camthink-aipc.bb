SUMMARY = "CamThink AIPC Platform Package Group"
DESCRIPTION = "Package group for CamThink AIPC platform including system dependencies and application"

PACKAGE_ARCH = "${MACHINE_ARCH}"
BUILDHISTORY_FEATURES:remove = "image package"

inherit packagegroup

PACKAGEGROUP_DISABLE_COMPLEMENTARY = "1"
PACKAGES = "${PN} ${PN}-system ${PN}-app"

# Part 1: System dependencies (binaries and libraries required by the system)
# These are system-level packages needed for the platform to function
RDEPENDS:${PN}-system = " \
    containerd-opencontainers \
    runc-opencontainers \
    cni \
    docker \
    python3-docker-compose \
    factory-eeprom-tool \
    u-boot-fw-utils \
    aipc-bootstrap \
    quectel-cm \
    camthink-rootfs \
"

# Part 2: CamThink AIPC application
# The actual application package (currently empty, add camthink-aipc when ready)
# Example: RDEPENDS:${PN}-app = " camthink-aipc"
RDEPENDS:${PN}-app = ""

# Main package group includes both system and application
RDEPENDS:${PN} = " \
    ${PN}-system \
    ${PN}-app \
"
