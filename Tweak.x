#define CHECK_TARGET
#import <dlfcn.h>
#import <HBLog.h>
#import <PSHeader/PS.h>
#import <version.h>

%ctor {
    if (isTarget(TargetTypeApps)) {
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiAttributes.dylib", RTLD_LAZY);
        HBLogDebug(@"EmojiAttributes.dylib: %s", dlerror());
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiResources.dylib", RTLD_LAZY);
        HBLogDebug(@"EmojiResources.dylib: %s", dlerror());
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiLayout.dylib", RTLD_LAZY);
        HBLogDebug(@"EmojiLayout.dylib: %s", dlerror());
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiLocalization.dylib", RTLD_LAZY);
        HBLogDebug(@"EmojiLocalization.dylib: %s", dlerror());
        if (IS_IOS_OR_NEWER(iOS_7_0)) {
            dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortiOS78.dylib", RTLD_LAZY);
            HBLogDebug(@"EmojiPortiOS78.dylib: %s", dlerror());
        }
#if !__LP64__
        else {
            dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortiOS6.dylib", RTLD_LAZY);
            HBLogDebug(@"EmojiPortiOS6.dylib: %s", dlerror());
        }
#endif
    }
}
