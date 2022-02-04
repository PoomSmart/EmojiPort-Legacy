#define CHECK_TARGET
#import <dlfcn.h>
#import "../PS.h"

%ctor {
    if (isTarget(TargetTypeApps)) {
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiAttributes.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiLayout.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiLocalization.dylib", RTLD_LAZY);
#if __LP64__
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortiOS78.dylib", RTLD_LAZY);
#else
        if (IS_IOS_OR_NEWER(iOS_7_0))
            dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortiOS78.dylib", RTLD_LAZY);
        else
            dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortiOS6.dylib", RTLD_LAZY);
#endif
    }
}
