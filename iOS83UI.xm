#define NO_EXTRA_ICONS
#import "Header.h"
#import "../EmojiLibrary/Header.h"
#import "../PSHeader/Misc.h"
#import <UIKit/UIKeyboardImpl.h>
#import <substrate.h>

@interface UIKeyboardEmojiScrollView (iOS83UI)
@property(retain, nonatomic) UILabel *_mycategoryLabel;
- (void)updateLabel:(NSInteger)categoryType;
@end

#define LABEL_HEIGHT (IS_IPAD ? 44.0 : 21.0)
#define FONT_SIZE (IS_IPAD ? 18.0 : 12.0)

void configureScrollView(UIKeyboardEmojiScrollView *self, CGRect frame) {
    if (self._mycategoryLabel == nil) {
        NSInteger orientation = [UIKeyboardImpl.activeInstance interfaceOrientation];
        CGPoint margin = [NSClassFromString(@"UIKeyboardEmojiGraphics") margin:orientation == 1 || orientation == 2];
        self._mycategoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin.x, 0.0, frame.size.width / 2, LABEL_HEIGHT)];
        self._mycategoryLabel.alpha = 0.4;
        CGFloat fontSize = FONT_SIZE;
        if (isiOS82Up)
            self._mycategoryLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold];
        else {
            if (isiOS6)
                fontSize -= 1.0;
            self._mycategoryLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        }
        self._mycategoryLabel.backgroundColor = UIColor.clearColor;
        [self updateLabel:MSHookIvar<UIKeyboardEmojiCategory *>(self, "_category").categoryType];
        [self addSubview:self._mycategoryLabel];
    }
}

%group iOS7Up

%hook UIKeyboardEmojiScrollView

- (id)initWithFrame:(CGRect)frame keyplane:(UIKBTree *)keyplane key:(UIKBTree *)key {
    self = %orig;
    configureScrollView(self, frame);
    return self;
}

- (void)setRenderConfig:(UIKBRenderConfig *)config {
    %orig;
    self._mycategoryLabel.textColor = config.whiteText ? UIColor.whiteColor : [UIColor colorWithWhite:0.2 alpha:1.0];
}

%end

%end

%hook UIKeyboardEmojiScrollView

%property(retain, nonatomic) UILabel *_mycategoryLabel;

%new
- (void)updateLabel:(NSInteger)categoryType {
    self._mycategoryLabel.text = [[[NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:categoryType] displayName] uppercaseStringWithLocale:[NSLocale currentLocale]];
}

-(void)layoutRecents {
    %orig;
    MSHookIvar<UILabel *>(self, "_categoryLabel").hidden = YES;
}

-(void)reloadForCategory:(UIKeyboardEmojiCategory *)category {
    %orig;
    [self updateLabel:category.categoryType];
}

-(void)doLayout {
    %orig;
    [self updateLabel:MSHookIvar<UIKeyboardEmojiCategory *>(self, "_category").categoryType];
}

%end

%hook PSEmojiLayout

+ (CGFloat)dotHeight {
    return LABEL_HEIGHT;
}

%end

#if !__LP64__

%group iOS6

%hook EmojiPageControl

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook UIKeyboardEmojiScrollView

- (id)initWithFrame:(CGRect)frame keyboard:(UIKBTree *)keyplane key:(UIKBTree *)key state:(NSInteger)state {
    self = %orig;
    configureScrollView(self, frame);
    return self;
}

%end

%end

#endif

%ctor {
    id r = [NSDictionary dictionaryWithContentsOfFile:realPrefPath(@"com.PS.Emoji10Legacy")][@"enabled"];
    BOOL enabled = r ? [r boolValue] : YES;
    if (enabled) {
#if TARGET_OS_SIMULATOR
        dlopen("/opt/simject/EmojiLayout.dylib", RTLD_LAZY);
        dlopen("/opt/simject/EmojiLocalization.dylib", RTLD_LAZY);
#else
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLayout.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLocalization.dylib", RTLD_LAZY);
#endif
        %init;
        if (isiOS7Up) {
            %init(iOS7Up);
        }
#if !__LP64__
        else {
            %init(iOS6);
        }
#endif
    }
}
