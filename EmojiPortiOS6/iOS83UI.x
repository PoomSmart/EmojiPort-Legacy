#import <EmojiLibrary/Header.h>
#import <PSHeader/Misc.h>
#import <UIKit/UIKeyboardImpl.h>
#import <theos/IOSMacros.h>
#import <substrate.h>
#import <version.h>

@interface UIKeyboardEmojiScrollView (iOS83UI)
@property (retain, nonatomic) UILabel *_mycategoryLabel;
- (void)updateLabel:(int)categoryType;
@end

#define LABEL_HEIGHT (IS_IPAD ? 44.0 : 21.0)
#define FONT_SIZE (IS_IPAD ? 18.0 : 12.0)

void configureScrollView(UIKeyboardEmojiScrollView *self, CGRect frame) {
    if (self._mycategoryLabel == nil) {
        NSInteger orientation = [UIKeyboardImpl.activeInstance interfaceOrientation];
        CGPoint margin = [%c(UIKeyboardEmojiGraphics) margin:orientation == 1 || orientation == 2];
        self._mycategoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin.x, 0.0, frame.size.width / 2, LABEL_HEIGHT)];
        self._mycategoryLabel.alpha = 0.4;
        CGFloat fontSize = FONT_SIZE;
        if (IS_IOS_OR_NEWER(iOS_8_2))
            self._mycategoryLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold];
        else {
#if !__LP64__
            if (!IS_IOS_OR_NEWER(iOS_7_0))
                fontSize -= 1.0;
#endif
            self._mycategoryLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        }
        self._mycategoryLabel.backgroundColor = UIColor.clearColor;
        [self updateLabel:((UIKeyboardEmojiCategory *)[self valueForKey:@"_category"]).categoryType];
        [self addSubview:self._mycategoryLabel];
    }
}

%hook UIKeyboardEmojiScrollView

%property (retain, nonatomic) UILabel *_mycategoryLabel;

%new(v@:i)
- (void)updateLabel:(int)categoryType {
    self._mycategoryLabel.text = [[[%c(UIKeyboardEmojiCategory) categoryForType:categoryType] displayName] uppercaseStringWithLocale:[NSLocale currentLocale]];
}

- (void)layoutRecents {
    %orig;
    ((UILabel *)[self valueForKey:@"_categoryLabel"]).hidden = YES;
}

- (void)reloadForCategory:(UIKeyboardEmojiCategory *)category {
    %orig;
    [self updateLabel:category.categoryType];
}

- (void)doLayout {
    %orig;
    [self updateLabel:((UIKeyboardEmojiCategory *)[self valueForKey:@"_category"]).categoryType];
}

%end

#if __LP64__

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

#endif

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
    id r = [NSDictionary dictionaryWithContentsOfFile:realPrefPath(@"com.PS.EmojiPortLegacy")][@"enabled"];
    BOOL enabled = r ? [r boolValue] : YES;
    if (enabled) {
        %init;
#if __LP64__
        %init(iOS7Up);
#else
        %init(iOS6);
#endif
    }
}
