PACKAGE_VERSION = 1.7.3~b3

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:8.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:6.0
	ARCHS = armv7 arm64
endif

include $(THEOS)/makefiles/common.mk

ifneq ($(SIMULATOR),1)
TWEAK_NAME = EmojiPortLegacy
EmojiPortLegacy_FILES = Tweak.xm
EmojiPortLegacy_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/tweak.mk
endif

SUBPROJECTS = EmojiPortiOS6 EmojiPortiOS78

include $(THEOS_MAKE_PATH)/aggregate.mk
include ../preferenceloader-sim/locatesim.mk

ifeq ($(SIMULATOR),1)
setup:: all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib /opt/simject/EmojiPortiOS6.dylib /opt/simject/EmojiPortiOS78.dylib
	@cp -v $(THEOS_OBJ_DIR)/EmojiPortiOS78.dylib /opt/simject
	@cp -v $(THEOS_OBJ_DIR)/EmojiPortiOS6.dylib /opt/simject
	@cp -v $(PWD)/EmojiPortiOS78.plist /opt/simject
	@cp -v $(PWD)/EmojiPortiOS6.plist /opt/simject
	$(ECHO_NOTHING)find $(PWD)/EmojiPortLegacy -name .DS_Store -delete$(ECHO_END)
	@sudo mkdir -p $(PL_SIMULATOR_PLISTS_PATH)
	@sudo cp -vR $(PWD)/EmojiPortLegacy $(PL_SIMULATOR_PLISTS_PATH)/
else
internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R EmojiPortLegacy $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/EmojiPortLegacy$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store -delete$(ECHO_END)
endif
