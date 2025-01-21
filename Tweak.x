#define CHECK_TARGET
#import <dlfcn.h>
#import <PSHeader/PS.h>

%ctor {
    if (isTarget(TargetTypeApps)) {
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiAttributes.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiResources.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiLayout.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiLocalization.dylib", RTLD_LAZY);
#if __LP64__
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortiOS78.dylib", RTLD_LAZY);
#else
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortiOS6.dylib", RTLD_LAZY);
#endif
    }
}
