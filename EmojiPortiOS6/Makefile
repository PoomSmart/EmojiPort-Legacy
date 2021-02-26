ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:8.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:6.0
	ARCHS = armv7
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EmojiPortiOS6
EmojiPortiOS6_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPort
EmojiPortiOS6_FILES = ../EmojiHUD.mm ../EmojiHUDSupport.xm ../Global.xm ../EmojiPicker.xm ../LegacyUI.xm ../iOS83UI.xm ../KBResizeLegacy.xm Tweak6.xm
EmojiPortiOS6_FRAMEWORKS = UIKit CoreGraphics CoreFoundation CoreText
EmojiPortiOS6_EXTRA_FRAMEWORKS = CydiaSubstrate
EmojiPortiOS6_LIBRARIES = EmojiLibrary
EmojiPortiOS6_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk
