#import "../EmojiLibrary/Header.h"
#import <UIKit/UIKeyboardInputMode.h>
#import <UIKit/UIKeyboardInputModeController.h>
#import <UIKit/UICompatibilityInputViewController.h>
#import <UIKit/UIKBInputBackdropView.h>
#import <UIKit/UIKBRenderConfig.h>
#import <UIKit/UIKBRenderTraits.h>
#import <UIKit/UIKBGradient.h>
#import <UIKit/UIPeripheralHost.h>
#import <UIKit/UIView+Private.h>
#import <UIKit/UITextInputTraits+Private.h>
#import <UIKit/UIResponder+Private.h>

/*extern "C" BOOL UIAccessibilityIsReduceTransparencyEnabled();

%subclass _UIBackdropViewSettingsLightEmojiKeyboard : _UIBackdropViewSettingsLightKeyboard

- (void)setDefaultValues {
    %orig;
    self.usesDarkeningTintView = NO;
    self.style = 3902;
    if (self.graphicsQuality != 0x28)
        self.colorTint = [UIColor colorWithRed:0.949020 green:0.956863 blue:0.968627 alpha:UIAccessibilityIsReduceTransparencyEnabled() ? 1.0 : 0.9];
}

%end*/

%hook _UIEmojiPageControl

- (void)setHidden: (BOOL)hidden {
    %orig(YES);
}

%end

/*%hook _UIBackdropViewSettings

+ (_UIBackdropViewSettings *)settingsForStyle:(NSInteger)style graphicsQuality:(NSInteger)graphicsQuality {
    return style == 3902 ? [[[%c(_UIBackdropViewSettingsLightEmojiKeyboard) alloc] initWithDefaultValuesForGraphicsQuality:graphicsQuality] autorelease] : %orig;
}

%end*/

%hook UIKBRenderFactory_Emoji

- (UIKBRenderTraits *)backgroundTraitsForKeyplane: (UIKBTree *)keyplane {
    UIKBRenderTraits *traits = %orig;
    if (self.renderConfig.lightKeyboard)
        traits.backgroundGradient = [NSClassFromString(@"UIKBGradient") gradientWithFlatColor:@"UIKBColorClear"];
    return traits;
}

- (UIKBRenderTraits *)_emojiCategoryControlKeyTraits {
    return [NSClassFromString(@ "UIKBRenderTraits") emptyTraits];
}

- (NSString *)_emojiBorderColor {
    return @"UIKBColorClear";
}

- (NSString *)controlKeyBackgroundColorName {
    return @"UIKBColorClear";
}

- (UIKBGradient *)_emojiInputViewKeyBackgroundColorGradient {
    return [NSClassFromString(@ "UIKBGradient") gradientWithFlatColor:@"UIKBColorClear"];
}

%end

%hook UIKBRenderFactoryEmoji_iPhone

- (UIKBRenderTraits *)_traitsForKey: (UIKBTree *)key onKeyplane: (UIKBTree *)keyplane {
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

/*%hook UIKBRenderConfig

%property(assign) BOOL useEmojiStyles;

%new
+ (UIKBRenderConfig *)defaultEmojiConfig {
    static UIKBRenderConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self defaultConfig] copy];
        config.useEmojiStyles = YES;
    });
    return config;
}

+ (UIKBRenderConfig *)configForAppearance:(NSInteger)appearance {
    if (appearance == 0) {
        UIKeyboardInputMode *inputMode = [[NSClassFromString(@"UIKeyboardInputModeController") sharedInputModeController] currentInputMode];
        return [inputMode isKindOfClass:NSClassFromString(@"UIKeyboardInputMode")] && [inputMode.identifier hasPrefix:@"emoji"] ? [self defaultEmojiConfig] : [self defaultConfig];
    }
    return %orig;
}

- (BOOL)isEqual:(UIKBRenderConfig *)config {
    return %orig && self.useEmojiStyles == config.useEmojiStyles;
}

- (UIKBRenderConfig *)copyWithZone:(NSZone *)zone {
    UIKBRenderConfig *config = %orig;
    config.useEmojiStyles = self.useEmojiStyles;
    return config;
}

- (NSInteger)backdropStyle {
    if (self.lightKeyboard)
        return 3901 + (self.useEmojiStyles ? 1 : 0);
    return %orig;
}

%end

%hook UIPeripheralHost

%new
- (UIKBRenderConfig *)_renderConfigForCurrentResponder {
    NSInteger appearance = [UITextInputTraits accessibleAppearanceForAppearance:[[self responder] respondsToSelector:@selector(keyboardAppearance)] ? [[self responder] keyboardAppearance] : 0];
    return [NSClassFromString(@"UIKBRenderConfig") configForAppearance:appearance];
}

%new
- (void)_updateRenderConfigForCurrentResponder {
    if ([[[self containerRootController].view _inheritedRenderConfig] backdropStyle] != [[self _renderConfigForCurrentResponder] backdropStyle])
        [self updateRenderConfigForCurrentResponder];
}

- (void)updateRenderConfigForCurrentResponder {
    if ([[self responder] _requiresKeyboardWhenFirstResponder])
        [[[self containerRootController] view] _setRenderConfig:[self _renderConfigForCurrentResponder]];
}

%group iOS82Up

- (void)_inputModeChanged:(id)arg1 {
    %orig;
    [self _updateRenderConfigForCurrentResponder];
}

%end

%group preiOS82

- (id)init {
    self = %orig;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_inputModeChanged:) name:@"UITextInputCurrentInputModeDidChangeNotification" object:nil];
    return self;
}

%new
- (void)_inputModeChanged:(id)arg1 {
    [self _updateRenderConfigForCurrentResponder];
}

%end

%end

%hook UIKBInputBackdropView

%property(assign) NSInteger style;
%property(assign) BOOL restrictStyle;

- (void)_setRenderConfig:(UIKBRenderConfig *)config {
    self.style = [config backdropStyle];
    %orig;
}

- (void)transitionToStyle:(NSInteger)style isSplit:(BOOL)isSplit {
    if (self.restrictStyle)
        style = self.style;
    self.style = style;
    %orig;
}

- (void)layoutInputBackdropToSplitWithLeftViewRect:(CGRect)leftRect andRightViewRect:(CGRect)rightRect innerCorners:(NSUInteger)innerCorners {
    self.restrictStyle = YES;
    %orig;
    self.restrictStyle = NO;
}

- (void)layoutInputBackdropToFullWithRect:(CGRect)rect {
    self.restrictStyle = YES;
    %orig;
    self.restrictStyle = NO;
}

%end

%hook UIKBBackgroundView

- (void)drawRect:(CGRect)rect {
    return;
}

%end

%hook UICompatibilityInputViewController

- (void)setInputMode:(UIKeyboardInputMode *)inputMode { 
    %orig;
    [[self inputController].view _setRenderConfig:[self.view _inheritedRenderConfig]];
}

%end*/

%ctor {
    id r = [NSDictionary dictionaryWithContentsOfFile:realPrefPath(@"com.PS.Emoji10Legacy")][@"enabled"];
    BOOL enabled = r ? [r boolValue] : YES;
    if (enabled) {
        %init;
        /*if (isiOS82Up) {
            %init(iOS82Up);
        } else {
            %init(preiOS82);
        }*/
    }
}