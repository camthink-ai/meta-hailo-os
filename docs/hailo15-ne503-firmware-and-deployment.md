# Hailo-15 (NE503) firmware recovery and system deployment

This guide describes how to recover low-level firmware and deploy the Linux system on a **Hailo-15 (NE503)** module from an **Ubuntu** host using **UART** and **TFTP**. Commands use example paths; replace `<MACHINE>` (`hailo15-ne503`, `hailo15-sbc`, etc.) and serial devices with values that match your setup.

---

## 1. Host setup

### 1.1 Install flashing tools

The **Hailo board tools** Python wheel provides the UART recovery and SPI flash utilities used below (`uart_boot_fw_loader`, `hailo15_spi_flash_program`). Install the version that matches your BSP release:

```bash
pip install tools/hailo15_board_tools-<VERSION>.whl
```

Install U-Boot helper utilities on the host:

```bash
sudo apt-get update
sudo apt-get install u-boot-tools
```

> **Note:** Recovery and bootloader binaries (`hailo15_uart_recovery_fw.bin`, `hailo15_scu_fw.bin`, signed U-Boot artifacts, certificates, etc.) are supplied with the Hailo tools/SDK package or are produced by your Yocto build under `tmp/deploy/images/<MACHINE>/`. Keep wheel version, binaries, and BSP aligned.

### 1.2 Find the serial device

Connect the NE503 UART to the PC and list stable device names:

```bash
ls -lh /dev/serial/by-id/
```

Example symlink target: `../../ttyACM0`.

The examples below use **`/dev/ttyACM0`** — change this to your actual device.

---

## 2. Recovery mode (low-level firmware)

Use this when the board must be recovered over UART before normal network boot.

### 2.1 DIP switches (UART programming mode)

Set the module to **UART programming mode**:

| Switch | Position |
|--------|----------|
| **BOOT0** | OFF |
| **BOOT1** | ON |

Then:

1. Apply the DIP settings.
2. Power the board.
3. Press **Reset** to enter the programming wait state.

### 2.2 Flash recovery firmware

```bash
uart_boot_fw_loader \
  --serial-device-name /dev/ttyACM0 \
  --firmware ./hailo15_uart_recovery_fw.bin
```

### 2.3 Flash bootloader stack (SCU, SPL, DTB, U-Boot)

This programs SCU firmware, U-Boot SPL, device tree, environment, customer certificate, and TF-A as a single flow:

```bash
hailo15_spi_flash_program \
  --scu-bootloader ./hailo15_scu_bl.bin \
  --scu-bootloader-config ./scu_bl_cfg_a.bin \
  --scu-firmware ./hailo15_scu_fw.bin \
  --uboot-device-tree ./u-boot.dtb.signed \
  --bootloader ./u-boot-spl.bin \
  --bootloader-env ./u-boot-initial-env \
  --customer-certificate ./customer_certificate.bin \
  --uboot-tfa ./u-boot-tfa.itb \
  --uart-load \
  --serial-device-name /dev/ttyACM0
```

---

## 3. TFTP server (host)

Images are large; TFTP is used to transfer `fitImage`, rootfs, and SWUpdate bundles to the board.

### 3.1 Install and configure `tftpd-hpa`

```bash
sudo apt update && sudo apt install tftpd-hpa
sudo nano /etc/default/tftpd-hpa
```

Set (or verify) the following:

```text
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/var/lib/tftpboot"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
```

### 3.2 Data directory and service

```bash
sudo mkdir -p /var/lib/tftpboot
sudo chown tftp:tftp /var/lib/tftpboot
sudo chmod 755 /var/lib/tftpboot
sudo systemctl restart tftpd-hpa
```

> For quick lab setups, broader permissions are sometimes used; tighten ownership and modes for production networks.

### 3.3 Publish build artifacts

Copy files from your build’s deploy directory to the TFTP root. Example for **`hailo15-ne503`**:

```bash
BUILD=build
MACHINE=hailo15-ne503
sudo cp ${BUILD}/tmp/deploy/images/${MACHINE}/fitImage /var/lib/tftpboot/
sudo cp ${BUILD}/tmp/deploy/images/${MACHINE}/swupdate-image-${MACHINE}.ext4.gz /var/lib/tftpboot/
sudo cp ${BUILD}/tmp/deploy/images/${MACHINE}/hailo-update-image-${MACHINE}.swu /var/lib/tftpboot/
```

Adjust `BUILD` if your OpenEmbedded build directory is not named `build`.

---

## 4. System programming and boot

### 4.1 Normal boot mode (DIP switches)

After recovery programming, switch back to **normal boot**:

| Switch | Position |
|--------|----------|
| **BOOT0** | OFF |
| **BOOT1** | OFF |

### 4.2 U-Boot menu

On power-up, use the serial console to open the U-Boot menu and pick a mode:

| Menu entry | Use case |
|------------|----------|
| **Autodetect** | Pick a boot source automatically; use when a system is already installed and you want the default behavior. |
| **Boot from SD Card** | Boot the existing rootfs from removable SD (no factory init). |
| **Boot from eMMC** | Boot the existing rootfs from onboard eMMC (no factory init). |
| **Boot from NFS** | Boot with kernel/rootfs over the network (NFS); requires host NFS export and matching `ipaddr` / `serverip`. |
| **SD Card Board Init** | **First-time / factory-style install:** provision a single system image onto SD (SWUpdate flow from TFTP as configured). |
| **SD Card AB Board Init** | Install an A/B redundant system onto SD. |
| **eMMC Board Init** | **First-time / factory-style install:** provision a single system onto eMMC (typical for production boards). |
| **eMMC AB Board Init** | Install an A/B redundant system onto eMMC. |
| **U-Boot console** | Interactive shell: `setenv`, manual `boot`, TFTP/NFS tweaks, diagnostics. |

Start flashing firmware to eMMC，choose **"eMMC Board Init"**

### 4.3 Network addresses (optional)

Defaults are often **device `10.0.0.1`** and **server `10.0.0.2`**. To change them, enter **U-Boot console** and run:

```text
setenv ipaddr 192.168.93.XXX
setenv serverip 192.168.93.YYY
saveenv
reset
```

Use addresses that match your LAN and TFTP host.

---

## 5. First login

When the image finishes installing and reboots, log in at the console or network:

| | |
|--|--|
| **User** | `root` |
| **Password** | `root` |

Change the password before deployment.

---