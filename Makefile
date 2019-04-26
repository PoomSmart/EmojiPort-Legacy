PACKAGE_VERSION = 1.6.13-1

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:8.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:6.0
endif

include $(THEOS)/makefiles/common.mk

ifneq ($(SIMULATOR),1)
TWEAK_NAME = Emoji10Legacy
Emoji10Legacy_FILES = Tweak.xm
Emoji10Legacy_FRAMEWORKS = UIKit
Emoji10Legacy_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/tweak.mk
endif

SUBPROJECTS = Emoji10iOS6 Emoji10iOS78

include $(THEOS_MAKE_PATH)/aggregate.mk
include ../preferenceloader/locatesim.mk

ifeq ($(SIMULATOR),1)
setup:: all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib /opt/simject/Emoji10iOS6.dylib /opt/simject/Emoji10iOS78.dylib
	@cp -v $(THEOS_OBJ_DIR)/Emoji10iOS78.dylib /opt/simject
	@cp -v $(THEOS_OBJ_DIR)/Emoji10iOS6.dylib /opt/simject
	@cp -v $(PWD)/Emoji10iOS78.plist /opt/simject
	@cp -v $(PWD)/Emoji10iOS6.plist /opt/simject
	$(ECHO_NOTHING)find $(PWD)/Emoji10Legacy -name .DS_Store -delete$(ECHO_END)
	@sudo cp -vR $(PWD)/Emoji10Legacy $(PL_SIMULATOR_PLISTS_PATH)/
else
internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R Emoji10Legacy $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Emoji10Legacy$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store -delete$(ECHO_END)
endif
