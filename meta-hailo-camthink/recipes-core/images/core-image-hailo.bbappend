# CamThink AIPC: production image also needs system deps + bootstrap.
# (core-image-minimal.bbappend does not apply when this recipe only requires
# that file — match the explicit install used by core-image-hailo-dev.)
IMAGE_INSTALL:append = " \
    packagegroup-camthink-aipc \
"
