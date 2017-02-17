LOCAL_PATH := $(call my-dir)

#ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
#-include device/fsl-codec/fsl-codec.mk
#endif
#include device/fsl-proprietary/media-profile/media-profile.mk
#include device/fsl-proprietary/sensor/fsl-sensor.mk

#----------------------------------------------------------------------
# Compile u-boot bootloader
#----------------------------------------------------------------------
ifneq ($(strip $(TARGET_NO_BOOTLOADER)),true)

# Compile
include bootable/bootloader/u-boot/AndroidBoot.mk

$(INSTALLED_BOOTLOADER_MODULE): $(TARGET_EMMC_BOOTLOADER) | $(ACP)
	$(transform-prebuilt-to-target)
$(BUILT_TARGET_FILES_PACKAGE): $(INSTALLED_BOOTLOADER_MODULE)

droidcore: $(INSTALLED_BOOTLOADER_MODULE)
endif

#----------------------------------------------------------------------
# Compile Linux Kernel
#----------------------------------------------------------------------
ifeq ($(KERNEL_DEFCONFIG),)
    ifeq ($(TARGET_BUILD_VARIANT),user)
      KERNEL_DEFCONFIG := msm-auto-perf_defconfig
    else
      KERNEL_DEFCONFIG := msm-auto_defconfig
    endif
endif

include kernel/AndroidKernel.mk

PATCH_KERNEL_TOOL := $(HOST_OUT_EXECUTABLES)/packkernelimg$(HOST_EXECUTABLE_SUFFIX)

ifneq ($(TARGET_KERNEL_DTB_LIST),)
$(info Selective dtb list : $(TARGET_KERNEL_DTB_LIST))
KERNEL_PATCH_EXTRA_ARGS := --dt_list "$(TARGET_KERNEL_DTB_LIST)"
else
KERNEL_PATCH_EXTRA_ARGS :=
endif

$(INSTALLED_KERNEL_TARGET): $(TARGET_PREBUILT_KERNEL) $(PATCH_KERNEL_TOOL) | $(ACP)

ifeq ($(TARGET_USES_UNCOMPRESSED_KERNEL),true)
	$(info Uncompressed kernel in use.Patching image)
	$(PATCH_KERNEL_TOOL) --kernel $(TARGET_PREBUILT_KERNEL) --dt $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/dts/qcom $(KERNEL_PATCH_EXTRA_ARGS)
endif
	$(transform-prebuilt-to-target)