# DDR profile selection for U-Boot SPL (fixed part-specific regconfig dtsi).
#
# Set DDR_PROFILE in local.conf or on the bitbake command line to switch DDR
# without editing patches. Profile names are added to MACHINEOVERRIDES so
# DDR_DTSI:<profile> is resolved automatically.
#
# Examples:
#   DDR_PROFILE = "mt53e1g32-4g-lp4"
#   DDR_PROFILE=mt53e2g32-8g-lp4x bitbake u-boot
#
# To bypass profiles, set DDR_DTSI directly to a hailo1x_ddr_*.dtsi filename.

DDR_PROFILE ?= "mt53e2g32-8g-lp4"
MACHINEOVERRIDES =. "${DDR_PROFILE}:"

# Profile → U-Boot arch/arm/dts/hailo1x_ddr_*.dtsi (from upstream u-boot tree).
DDR_DTSI:mt53e512-2g-lp4x = "hailo1x_ddr_MT53E512M32D1-046_regconfig_2GB_LP4X.dtsi"
DDR_DTSI:mt53e512-2g-lp4  = "hailo1x_ddr_MT53E512M32D1-046_regconfig_2GB_LP4.dtsi"
DDR_DTSI:mt53e256-1g-lp4x = "hailo1x_ddr_MT53E256M32D1-046_regconfig_1GB_LP4X.dtsi"
DDR_DTSI:mt53e1g32-4g-lp4  = "hailo1x_ddr_MT53E1G32D2FW-046-B_regconfig_4GB_LP4.dtsi"
DDR_DTSI:mt53e1g32-4g-lp4x = "hailo1x_ddr_MT53E1G32D2FW-046-B_regconfig_4GB_LP4X.dtsi"
DDR_DTSI:mt53e1g32c-4g-lp4 = "hailo1x_ddr_MT53E1G32D2FW-046-C_regconfig_4GB_LP4.dtsi"
DDR_DTSI:mt53e2g32-8g-lp4x = "hailo1x_ddr_MT53E2G32D4DE-046_regconfig_8GB_LP4X.dtsi"
DDR_DTSI:mt53e2g32-8g-lp4  = "hailo1x_ddr_MT53E2G32D4DE-046_regconfig_8GB_LP4.dtsi"
DDR_DTSI:rs2g32-8g-lp4 = "hailo1x_ddr_RS2G32LV4D4BDT_regconfig_8GB_LP4.dtsi"
DDR_DTSI:h9hcnnncpumlxr-4g-lp4 = "hailo1x_ddr_H9HCNNNCPUMLXR_NEE_regconfig_4GB_LP4.dtsi"

DDR_DTSI ?= "hailo1x_ddr_MT53E512M32D1-046_regconfig_2GB_LP4X.dtsi"

# U-Boot board DTS to patch (machine-specific basename under arch/arm/dts/).
UBOOT_BOARD_DTS ??= ""
