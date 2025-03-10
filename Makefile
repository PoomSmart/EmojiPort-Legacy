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
$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/tweak.mk
endif

SUBPROJECTS = EmojiPortiOS6 EmojiPortiOS78

include $(THEOS_MAKE_PATH)/aggregate.mk

ifeq ($(SIMULATOR),1)
include ../../Simulator/preferenceloader-sim/locatesim.mk
setup:: all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib /opt/simject/EmojiPortiOS6.dylib /opt/simject/EmojiPortiOS78.dylib
	@cp -v $(THEOS_OBJ_DIR)/EmojiPortiOS78.dylib /opt/simject
	@cp -v $(THEOS_OBJ_DIR)/EmojiPortiOS6.dylib /opt/simject
	@cp -v $(PWD)/EmojiPortiOS78.plist /opt/simject
	@cp -v $(PWD)/EmojiPortiOS6.plist /opt/simject
	@sudo mkdir -p $(PL_SIMULATOR_PLISTS_PATH)
	@sudo cp -vR $(PWD)/layout/Library/PreferenceLoader/Preferences/EmojiPortLegacy $(PL_SIMULATOR_PLISTS_PATH)/
endif
