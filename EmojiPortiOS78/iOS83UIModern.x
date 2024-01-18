#import <EmojiLibrary/Header.h>
#import <PSHeader/Misc.h>
#import <UIKit/UIKBRenderConfig.h>
#import <UIKit/UIKBRenderTraits.h>
#import <UIKit/UIKBGradient.h>

%hook _UIEmojiPageControl

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook UIKBRenderFactory_Emoji

- (UIKBRenderTraits *)backgroundTraitsForKeyplane:(UIKBTree *)keyplane {
    UIKBRenderTraits *traits = %orig;
    if (self.renderConfig.lightKeyboard)
        traits.backgroundGradient = [%c(UIKBGradient) gradientWithFlatColor:@"UIKBColorClear"];
    return traits;
}

- (UIKBRenderTraits *)_emojiCategoryControlKeyTraits {
    return [%c(UIKBRenderTraits) emptyTraits];
}

- (NSString *)_emojiBorderColor {
    return @"UIKBColorClear";
}

- (NSString *)controlKeyBackgroundColorName {
    return @"UIKBColorClear";
}

- (UIKBGradient *)_emojiInputViewKeyBackgroundColorGradient {
    return [%c(UIKBGradient) gradientWithFlatColor:@"UIKBColorClear"];
}

%end

%hook UIKBRenderFactoryEmoji_iPhone

- (UIKBRenderTraits *)_traitsForKey:(UIKBTree *)key onKeyplane:(UIKBTree *)keyplane {
    UIKBRenderTraits *traits = %orig;
    if ((key.displayType == 0x3 || key.displayType == 0x5 || key.displayType == 0xd || key.displayType == 0x19 || key.displayType == 0x25) && (key.state & 2)) {
        traits.backgroundGradient = nil;
        traits.layeredBackgroundGradient = nil;
        [traits removeAllRenderEffects];
    } else if (key.displayType == 0x24)
        traits.backgroundGradient = nil;
    return traits;
}

%end

%ctor {
    id r = [NSDictionary dictionaryWithContentsOfFile:realPrefPath(@"com.PS.EmojiPortLegacy")][@"enabled"];
    BOOL enabled = r ? [r boolValue] : YES;
    if (enabled) {
        %init;
    }
}