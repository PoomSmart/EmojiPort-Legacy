#import "../EmojiLibrary/Header.h"

#define EmojiHUDHoldInterval 0.35

@interface EmojiHUD : UIView {
	BOOL _showing;
	NSString *_emojiString;
}
+ (instancetype)sharedInstance;
@property BOOL showing;
- (void)show;
- (void)hide;
- (void)show:(BOOL)show;
- (void)showWithEmojiView:(UIKeyboardEmojiView *)emojiView;
@end
