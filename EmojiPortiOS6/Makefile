ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:8.0
	ARCHS = i386
else
	TARGET = iphone:clang:latest:6.0
	ARCHS = armv7
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EmojiPortiOS6
$(LIBRARY_NAME)_FILES = ../EmojiHUD.mm ../EmojiHUDSupport.x ../Global.xm ../EmojiPicker.x ../LegacyUI.xm ../iOS83UI.x ../KBResizeLegacy.x Tweak6.xm
$(LIBRARY_NAME)_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPort
$(LIBRARY_NAME)_FRAMEWORKS = UIKit CoreGraphics CoreFoundation CoreText
$(LIBRARY_NAME)_EXTRA_FRAMEWORKS = CydiaSubstrate
$(LIBRARY_NAME)_LIBRARIES = EmojiLibrary
$(LIBRARY_NAME)_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk
