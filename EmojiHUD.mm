#import "EmojiHUD.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import <UIKit/UIKeyboard.h>
#import <substrate.h>

@implementation EmojiHUD

@synthesize showing = _showing;

+ (CGRect)hudFrame {
    CGFloat width = IS_IPAD ? 300.0 : 260.0;
    CGFloat height = IS_IPAD ? 55.0 : 40.0;
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat x = (bounds.size.width - width) / 2;
    CGFloat y = (bounds.size.height - height) / 2;
    if (IS_IPAD && bounds.size.height > 768.0)
        y += 140.0;
    return CGRectMake(x, y, width, height);
}

+ (UIView *)hudWindow {
    return UIKeyboard.activeKeyboard.window;
}

+ (EmojiHUD *)sharedInstance {
    static EmojiHUD *sharedHUD = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHUD = [[self alloc] init];
        sharedHUD.frame = [self hudFrame];
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
        self.frame = [[self class] hudFrame];
}

- (void)show {
    [self show:YES];
}

- (void)emojiUsed:(UIKeyboardEmoji *)emoji {
    if (!emoji || !emoji.emojiString.length)
        return;
    UIKeyboardEmojiInputController *controller = (UIKeyboardEmojiInputController *)[[NSClassFromString(@"UIKeyboardEmojiInputController") activeInputView] valueForKey:@"_inputController"];
    [controller emojiUsed:emoji];
    [self hide];
}

- (NSArray <NSString *> *)variantsForEmoji:(NSString *)emojiString {
    return [PSEmojiUtilities skinToneVariants:emojiString isSkin:YES];
}

- (UIKeyboardEmoji *)emojiFromVariant:(NSInteger)variant {
    return [PSEmojiUtilities emojiWithString:[PSEmojiUtilities skinToneVariant:self->_emojiString skin:[PSEmojiUtilities skinModifiers][variant - 1]]];
}

- (void)emojiUsedInVariant:(NSInteger)variant {
    [self emojiUsed:[self emojiFromVariant:variant]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGFloat vf = [touch locationInView:touch.view].x / (self.frame.size.width / 5.0);
#if __LP64__
    NSInteger variant = (NSInteger)ceil(vf);
#else
    NSInteger variant = (NSInteger)ceilf(vf);
#endif
    [self emojiUsedInVariant:variant];
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
        CGRect frame = emojiView.frame;
        CGFloat gap = (totalWidth - (5 * emojiWidth)) / 6;
        frame = CGRectMake(gap, (totalHeight - emojiHeight) / 2, emojiWidth, emojiHeight);
        NSArray <NSString *> *variants = [self variantsForEmoji:emojiString];
        for (NSString *variant in variants) {
            UIKeyboardEmojiView *diverse = [NSClassFromString(@"UIKeyboardEmojiView") emojiViewForEmoji:[PSEmojiUtilities emojiWithString:variant] withFrame:frame];
            [self addSubview:diverse];
            diverse.userInteractionEnabled = NO;
            frame = CGRectMake(frame.origin.x + gap + emojiWidth, frame.origin.y, frame.size.width, frame.size.height);
        }
    }
}

- (void)hide {
    if (self.showing)
        [self show:NO];
}

@end
