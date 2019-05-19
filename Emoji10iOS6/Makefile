ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:8.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:6.0
	ARCHS = armv7
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = Emoji10iOS6
Emoji10iOS6_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/Emoji10Legacy
Emoji10iOS6_FILES = ../EmojiHUD.mm ../EmojiHUDSupport.xm ../Global.xm ../EmojiPicker.xm ../LegacyUI.xm ../iOS83UI.xm ../KBResizeLegacy.xm Tweak.xm
Emoji10iOS6_FRAMEWORKS = UIKit CoreGraphics CoreFoundation CoreText
Emoji10iOS6_EXTRA_FRAMEWORKS = CydiaSubstrate
Emoji10iOS6_LIBRARIES = EmojiLibrary
Emoji10iOS6_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk
