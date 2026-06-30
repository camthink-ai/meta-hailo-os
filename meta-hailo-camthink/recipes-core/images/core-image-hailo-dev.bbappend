# CamThink AIPC: Install packagegroup for system dependencies and application
# System dependencies (containerd, runc, cni) are now managed through packagegroup
IMAGE_INSTALL:append = " \
    packagegroup-camthink-aipc \
"
