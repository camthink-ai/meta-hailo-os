# Meta Hailo OS

> Yocto/OpenEmbedded BSP layer for CamThink AIPC on Hailo15. 

## Overview

| | |
|---|---|
| **Layer** | `meta-hailo-camthink` |
| **Machines** | `hailo15-ne503` |

## Prerequisites

- [kas](https://pypi.org/project/kas/) — `pip install kas`

## Quick Start

### Standalone (clone this repo only)

```bash
git clone https://github.com/camthink-ai/meta-hailo-os.git
cd meta-hailo-os

# Dev / debug image + SWU (hailo-dev-pkg; larger)
kas build kas/hailo15-ne503.yml

# Core / slim image + SWU (hailo-core; smaller OTA)
kas build kas/hailo15-ne503-core.yml
```

`hailo15-ne503-core.yml` builds `core-image-hailo` + `hailo-update-image-core-*`
without `hailo-dev-pkg` extras (CLIP/demo HEFs, medialib tuning tools, imaging
static libs, perfetto). Use it for release OTA; keep `hailo15-ne503.yml` for lab/dev.

### Toolchain (SDK)

```bash
source poky/oe-init-build-env
# Build SDK for current image
bitbake core-image-hailo-dev -c populate_sdk
# Or production image SDK:
# bitbake core-image-hailo -c populate_sdk
# Or minimal toolchain only
bitbake meta-toolchain
```

Install the generated `.sh` under `tmp/deploy/sdk/`, then:

```bash
./tmp/deploy/sdk/<sdk-name>.sh
source /path/to/sdk/environment-setup-*
```

## Firmware recovery and system deployment

After `bitbake`, images appear under `build/tmp/deploy/images/<MACHINE>/` (adjust if your build directory name differs).

**How to use (full procedure):** follow **[docs/hailo15-ne503-firmware-and-deployment.md](docs/hailo15-ne503-firmware-and-deployment.md)**

## Repository Layout

| Path | Description |
|------|-------------|
| `kas/` | KAS configs; entries `hailo15-ne503.yml` (dev), `hailo15-ne503-core.yml` (slim) |
| `meta-hailo-camthink/` | BSP layer (conf, machine, recipes-*) |

## Contact

[camthink.ai](https://www.camthink.ai/company/contact-us/)
