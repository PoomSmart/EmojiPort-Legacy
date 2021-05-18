#import "EmojiHUD.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLayout/PSEmojiLayout.h"
#import <UIKit/UIKit.h>
#import <UIKit/UIKeyboard.h>
#import <theos/IOSMacros.h>
#import <substrate.h>
#import <version.h>

#define MAX_PER_ROW 5

@implementation EmojiHUD

- (void)calculateRect:(int)count {
    CGFloat width = IS_IPAD ? 300.0 : 260.0;
    CGFloat height = IS_IPAD ? 55.0 : 40.0;
    if (count > MAX_PER_ROW) {
        self.multiline = YES;
#if __LP64__
    height *= 1.05 * ceil((double)count / MAX_PER_ROW);
#else
    height *= 1.05 * ceilf((float)count / MAX_PER_ROW);
#endif  
    } else
        self.multiline = NO;
    BOOL isPortrait = [SoftPSEmojiLayout isPortrait];
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat screenWidth = bounds.size.width;
    CGFloat screenHeight = bounds.size.height;
    if (!isPortrait) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    CGFloat x = (screenWidth - width) / 2;
    CGFloat y = (screenHeight - height) / 2;
    if (IS_IPAD && screenHeight > 768.0)
        y += 140.0;
    self.frame = CGRectMake(x, y, width, height);
}

+ (UIView *)hudWindow {
    return UIKeyboard.activeKeyboard.window;
}

+ (EmojiHUD *)sharedInstance {
    static EmojiHUD *sharedHUD = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHUD = [[self alloc] init];
        sharedHUD.hidden = YES;
        sharedHUD.showing = NO;
        [[self hudWindow] addSubview:sharedHUD];
    });
    return sharedHUD;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    self.layer.cornerRadius = 12.0;
    return self;
}

- (void)clearViews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.subviews makeObjectsPerformSelector:@selector(release)];
}

- (void)show:(BOOL)show {
    self.showing = show;
    self.hidden = !show;
    if (show)
        [self calculateRect:0];
}

- (void)show {
    [self show:YES];
}

- (void)emojiUsed:(UIKeyboardEmoji *)emoji {
    if (!emoji || !emoji.emojiString.length)
        return;
    if (IS_IOS_OR_NEWER(iOS_6_0)) {
        UIKeyboardEmojiInputController *controller = (UIKeyboardEmojiInputController *)[[NSClassFromString(@"UIKeyboardEmojiInputController") activeInputView] valueForKey:@"_inputController"];
        [controller emojiUsed:emoji];
    } else
        [(UIKeyboardLayoutEmoji *)[NSClassFromString(@"UIKeyboardLayoutEmoji") emojiLayout] emojiSelected:emoji];
    [self hide];
}

- (NSArray <NSString *> *)variantsForEmoji:(NSString *)emojiString {
    return [PSEmojiUtilities skinToneVariants:emojiString isSkin:YES];
}

- (UIKeyboardEmoji *)emojiFromIndex:(NSInteger)index {
    NSString *emojiString = self.multiline
        ? [PSEmojiUtilities skinToneVariants:self->_emojiString][index]
        : [PSEmojiUtilities skinToneVariant:self->_emojiString skin:[PSEmojiUtilities skinModifiers][index - 1]];
    return [PSEmojiUtilities emojiWithString:emojiString];
}

- (void)emojiUsedAtIndex:(NSInteger)index {
    [self emojiUsed:[self emojiFromIndex:index]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint pos = [touch locationInView:touch.view];
    CGFloat xPos = pos.x / (self.frame.size.width / MAX_PER_ROW);
    CGFloat yPos = pos.y / self.frame.size.height;
    CGFloat yPosFinal = self.multiline ? yPos * MAX_PER_ROW : yPos;
#if __LP64__
    CGFloat xPosFinal = self.multiline ? floor(xPos) : ceil(xPos);
    NSInteger index = (NSInteger)xPosFinal + (MAX_PER_ROW * (NSInteger)floor(yPosFinal));
#else
    CGFloat xPosFinal = self.multiline ? floorf(xPos) : ceilf(xPos);
    NSInteger index = (NSInteger)xPosFinal + (MAX_PER_ROW * (NSInteger)floorf(yPosFinal));
#endif
    [self emojiUsedAtIndex:index];
}

- (void)showWithEmojiView:(UIKeyboardEmojiView *)emojiView {
    [self clearViews];
    [self show];
    NSString *emojiString = emojiView.emoji.emojiString;
    if (emojiString) {
        self->_emojiString = emojiString;
        CGRect hudFrame = self.frame;
        CGFloat totalWidth = hudFrame.size.width;
        CGFloat totalHeight = hudFrame.size.height;
        CGFloat emojiWidth = emojiView.frame.size.width;
        CGFloat emojiHeight = emojiView.frame.size.height;
        CGFloat gapX = (totalWidth - (MAX_PER_ROW * emojiWidth)) / (MAX_PER_ROW + 1);
        CGRect frame = CGRectMake(gapX, (totalHeight - emojiHeight) / 2, emojiWidth, emojiHeight);
        NSArray <NSString *> *variants = [self variantsForEmoji:emojiString];
        [self calculateRect:variants.count];
        int i = 1;
        CGFloat ixPos = frame.origin.x;
        CGFloat xPos = ixPos;
        CGFloat yPos = frame.origin.y;
        for (NSString *variant in variants) {
            UIKeyboardEmojiView *diverse = [NSClassFromString(@"UIKeyboardEmojiView") emojiViewForEmoji:[PSEmojiUtilities emojiWithString:variant] withFrame:frame];
            [self addSubview:diverse];
            diverse.userInteractionEnabled = NO;
            if (i++ % MAX_PER_ROW == 0) {
                xPos = ixPos;
                yPos += emojiHeight + gapX;
            } else
                xPos += gapX + emojiWidth;
            frame = CGRectMake(xPos, yPos, frame.size.width, frame.size.height);
        }
    }
}

- (void)hide {
    if (self.showing)
        [self show:NO];
}

@end
