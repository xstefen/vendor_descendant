# Bring in Qualcomm helper macros
include vendor/descendant/build/core/qcom_utils.mk

# Platform names
KONA := kona #SM8250
LITO := lito #SM7250
MSMNILE := msmnile #SM8150
MSMSTEPPE := sm6150
TRINKET := trinket #SM6125
ATOLL := atoll #SM6250

B_FAMILY := msm8226 msm8610 msm8974
B64_FAMILY := msm8992 msm8994
BR_FAMILY := msm8909 msm8916
UM_3_18_FAMILY := msm8937 msm8953 msm8996
UM_4_4_FAMILY := msm8998 sdm660
UM_4_9_FAMILY := sdm845 sdm710
UM_4_14_FAMILY := $(MSMNILE) $(MSMSTEPPE) $(TRINKET) $(ATOLL)
UM_4_19_FAMILY := $(KONA) $(LITO)
UM_PLATFORMS := $(UM_3_18_FAMILY) $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY)
QSSI_SUPPORTED_PLATFORMS := $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY)

BOARD_USES_ADRENO := true

# UM platforms no longer need this set on O+
ifneq ($(call is-board-platform-in-list, $(UM_PLATFORMS)),true)
TARGET_USES_QCOM_BSP := true
endif

# Tell HALs that we're compiling an AOSP build with an in-line kernel
TARGET_COMPILE_WITH_MSM_KERNEL := true

ifneq ($(filter msm7x27a msm7x30 msm8660 msm8960,$(PRODUCT_BOARD_PLATFORM)),)
TARGET_USES_QCOM_BSP_LEGACY := true
# Enable legacy audio functions
ifeq ($(BOARD_USES_LEGACY_ALSA_AUDIO),true)
    USE_CUSTOM_AUDIO_POLICY := 1
endif
endif

# Enable media extensions
TARGET_USES_MEDIA_EXTENSIONS := true

# Allow building audio encoders
TARGET_USES_QCOM_MM_AUDIO := true

# Enable color metadata for every UM platform
ifeq ($(call is-board-platform-in-list, $(UM_PLATFORMS)),true)
TARGET_USES_COLOR_METADATA := true
endif

# Enable DRM PP driver on UM platforms that support it
ifeq ($(call is-board-platform-in-list, $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY)),true)
TARGET_USES_DRM_PP := true
endif

# Mark GRALLOC_USAGE_HW_2D, GRALLOC_USAGE_EXTERNAL_DISP and GRALLOC_USAGE_PRIVATE_WFD as valid gralloc bits
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS ?= 0
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 10)
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 13)
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 21)

# Mark GRALLOC_USAGE_PRIVATE_HEIF_VIDEO as valid gralloc bits on UM platforms that support it
ifeq ($(call is-board-platform-in-list, $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY)),true)
    TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS += | (1 << 27)
endif

# List of targets that use master side content protection
MASTER_SIDE_CP_TARGET_LIST := msm8996 $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY)

ifeq ($(call is-board-platform-in-list, $(B_FAMILY)),true)
MSM_VIDC_TARGET_LIST := $(B_FAMILY)
QCOM_HARDWARE_VARIANT := msm8974
else ifeq ($(call is-board-platform-in-list, $(B64_FAMILY)),true)
MSM_VIDC_TARGET_LIST := $(B64_FAMILY)
QCOM_HARDWARE_VARIANT := msm8994
else ifeq ($(call is-board-platform-in-list, $(BR_FAMILY)),true)
MSM_VIDC_TARGET_LIST := $(BR_FAMILY)
QCOM_HARDWARE_VARIANT := msm8916
else ifeq ($(call is-board-platform-in-list, $(UM_3_18_FAMILY)),true)
MSM_VIDC_TARGET_LIST := $(UM_3_18_FAMILY)
QCOM_HARDWARE_VARIANT := msm8996
else ifeq ($(call is-board-platform-in-list, $(UM_4_4_FAMILY)),true)
MSM_VIDC_TARGET_LIST := $(UM_4_4_FAMILY)
QCOM_HARDWARE_VARIANT := msm8998
else ifeq ($(call is-board-platform-in-list, $(UM_4_9_FAMILY)),true)
MSM_VIDC_TARGET_LIST := $(UM_4_9_FAMILY)
QCOM_HARDWARE_VARIANT := sdm845
else ifeq ($(call is-board-platform-in-list, $(UM_4_14_FAMILY)),true)
MSM_VIDC_TARGET_LIST := $(UM_4_14_FAMILY)
QCOM_HARDWARE_VARIANT := sm8150
else ifeq ($(call is-board-platform-in-list, $(UM_4_19_FAMILY)),true)
MSM_VIDC_TARGET_LIST := $(UM_4_19_FAMILY)
QCOM_HARDWARE_VARIANT := sm8250
else
MSM_VIDC_TARGET_LIST := $(PRODUCT_BOARD_PLATFORM)
QCOM_HARDWARE_VARIANT := $(PRODUCT_BOARD_PLATFORM)
endif


# Add display-commonsys-intf to PRODUCT_SOONG_NAMESPACES for QSSI supported platforms
ifneq ($(filter $(QSSI_SUPPORTED_PLATFORMS),$(PRODUCT_BOARD_PLATFORM)),)
    PRODUCT_SOONG_NAMESPACES += vendor/qcom/opensource/commonsys-intf/display
endif

QCOM_SOONG_NAMESPACE ?= hardware/qcom-caf/$(QCOM_HARDWARE_VARIANT)
PRODUCT_SOONG_NAMESPACES += $(QCOM_SOONG_NAMESPACE)

ifeq ($(TARGET_USE_QTI_BT_STACK),true)
PRODUCT_SOONG_NAMESPACES += \
    vendor/qcom/opensource/commonsys/packages/apps/Bluetooth \
    vendor/qcom/opensource/commonsys/system/bt/conf
endif #TARGET_USE_QTI_BT_STACK
include vendor/descendant/build/core/qcom_target.mk
