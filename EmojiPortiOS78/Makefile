ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:7.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:7.0
	ARCHS = armv7 arm64
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EmojiPortiOS78
EmojiPortiOS78_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPortLegacy
EmojiPortiOS78_FILES = ../EmojiHUD.mm ../EmojiHUDSupport.xm ../Global.xm ../EmojiPicker.xm ../LegacyUI.xm ../iOS83UI.xm iOS83UIModern.xm KBResize78.xm ../KBResizeLegacy.xm Tweak.xm
ifeq ($(SIMULATOR),1)
	EmojiPortiOS78_FILES += NoKeyboardCache.xm
endif
EmojiPortiOS78_FRAMEWORKS = UIKit CoreGraphics CoreFoundation
EmojiPortiOS78_EXTRA_FRAMEWORKS = CydiaSubstrate
EmojiPortiOS78_LIBRARIES = EmojiLibrary
EmojiPortiOS78_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk
