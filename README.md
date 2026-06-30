# Meta Hailo OS

> Yocto/OpenEmbedded BSP layer for CamThink AIPC on Hailo15. 

## Overview

| | |
|---|---|
| **Layer** | `meta-hailo-camthink` |
| **Machines** | `hailo15-ne503`, `hailo15-sbc` |

## Prerequisites

- [kas](https://pypi.org/project/kas/) — `pip install kas`

## Quick Start

### Standalone (clone this repo only)

```bash
git clone https://github.com/camthink-ai/meta-hailo-os.git
cd meta-hailo-os
kas build kas/hailo15-ne503.yml
```

### Toolchain (SDK)

```bash
source poky/oe-init-build-env
# Build SDK for current image
bitbake core-image-hailo-dev -c populate_sdk
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
| `kas/` | KAS configs; entries `hailo15-ne503.yml`, `hailo15-sbc.yml` |
| `meta-hailo-camthink/` | BSP layer (conf, machine, recipes-*) |

## Contact

[camthink.ai](https://www.camthink.ai/company/contact-us/)
