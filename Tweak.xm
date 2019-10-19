#define CHECK_TARGET
#import <dlfcn.h>
#import "../PS.h"

%ctor {
    if (isTarget(TargetTypeApps)) {
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiAttributesRun.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLayout.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLocalization.dylib", RTLD_LAZY);
        if (isiOS7Up)
            dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPortLegacy/EmojiPortiOS78.dylib", RTLD_LAZY);
#if !__LP64__
        else
            dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPortLegacy/EmojiPortiOS6.dylib", RTLD_LAZY);
#endif
    }
}
