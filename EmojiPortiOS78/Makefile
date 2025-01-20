ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:7.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:7.0
	ARCHS = armv7 arm64
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EmojiPortiOS78
$(LIBRARY_NAME)_FILES = ../EmojiHUD.mm EmojiHUDSupport.x Global.xm EmojiPicker.x LegacyUI.xm iOS83UI.x iOS83UIModern.x KBResize78.xm KBResizeLegacy.x Tweak78.xm
ifeq ($(SIMULATOR),1)
	$(LIBRARY_NAME)_FILES += NoKeyboardCache.x
endif
$(LIBRARY_NAME)_CFLAGS = -fobjc-arc
$(LIBRARY_NAME)_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPort
$(LIBRARY_NAME)_FRAMEWORKS = UIKit CoreGraphics CoreFoundation
$(LIBRARY_NAME)_EXTRA_FRAMEWORKS = CydiaSubstrate
$(LIBRARY_NAME)_LIBRARIES = EmojiLibrary
$(LIBRARY_NAME)_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk
