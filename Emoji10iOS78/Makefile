ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:7.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:7.0
	ARCHS = armv7 arm64
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = Emoji10iOS78
Emoji10iOS78_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/Emoji10Legacy
Emoji10iOS78_FILES = ../EmojiHUD.mm ../EmojiHUDSupport.xm ../Global.xm ../LegacyUI.xm ../iOS83UI.xm iOS83UIModern.xm KBResize78.xm ../KBResizeLegacy.xm Tweak.xm
ifeq ($(SIMULATOR),1)
	Emoji10iOS78_FILES += NoKeyboardCache.xm
endif
Emoji10iOS78_FRAMEWORKS = UIKit CoreGraphics CoreFoundation
Emoji10iOS78_EXTRA_FRAMEWORKS = CydiaSubstrate
Emoji10iOS78_LIBRARIES = Accessibility EmojiLibrary
Emoji10iOS78_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk
