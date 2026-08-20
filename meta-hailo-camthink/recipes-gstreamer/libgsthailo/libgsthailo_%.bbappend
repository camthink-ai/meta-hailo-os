FILESEXTRAPATHS:prepend := "${@os.path.join(os.path.dirname(d.getVar('FILE')), '..', '..', 'recipes-hailo', 'libhailort')}:"

SRC_URI:append = " file://0001-libhailort-set-stable-soname.patch"
