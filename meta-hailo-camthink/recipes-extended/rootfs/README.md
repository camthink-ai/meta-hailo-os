# camthink-rootfs

Custom scripts and files that must ship in the NE503 (and other CamThink AIPC)
rootfs image.

## Layout

```
rootfs/
├── camthink-rootfs_1.0.bb
├── README.md
└── files/
    └── overlay/          # mirrors target filesystem paths
        └── usr/local/bin/example.sh   # -> /usr/local/bin/example.sh
```

Place content **under `files/overlay/`** using the destination path (no leading
`/`). Examples:

| Overlay path | On device |
|--------------|-----------|
| `usr/local/bin/ct-cell` | `/usr/local/bin/ct-cell` |
| `etc/camthink/bar.conf` | `/etc/camthink/bar.conf` |

Do **not** put files next to the recipe outside `files/overlay/` — BitBake only
fetches `file://overlay/`.

### Shipped helpers

- **`ct-cell`** — NE503/EM05 shell tool: `status` / `power` / `reset` /
  `dial` / `hangup` / **`at`** (auto AT port) / **`sim`** (`AT+CPIN?`).
  Defaults match `cellular-hw.yaml` (`gpiochip1` pwr=7, reset=5).
  Override AT with `CELLULAR_AT_PORT`. Production path remains platform-api.

## Image inclusion

Package name: `camthink-rootfs`  
Pulled in via `packagegroup-camthink-aipc` (`RDEPENDS:${PN}-system`).

## Notes

- Prefer this recipe for small static scripts/configs owned by the OS image.
- Large AIPC runtime payloads still go under `/data/aipc` via neoruntime deploy,
  not this overlay.
- After adding files, rebuild the image (or `bitbake camthink-rootfs` then the
  image recipe) so rootfs picks up the package.
