#import "EmojiHUD.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"

BOOL from;
NSTimer *__showHUD;
UIKeyboardEmojiView *_emojiView;

void clearTimer() {
    if (__showHUD) {
        [__showHUD invalidate];
        __showHUD = nil;
    }
}

%hook UIKeyboardEmojiPage

%new
- (void)_showHUD {
    if (EmojiHUD.sharedInstance.showing)
        [EmojiHUD.sharedInstance hide];
    else {
        from = YES;
        [self touchCancelled:[self activeTouch]];
        from = NO;
        [EmojiHUD.sharedInstance showWithEmojiView:_emojiView];
    }

}

- (void)setOnDisplay:(UIKeyboardEmojiView *)emojiView {
    %orig;
    if (emojiView) {
        BOOL supportsSkin = emojiView.emoji.supportsSkin;
        if (!supportsSkin)
            return;
        _emojiView = emojiView;
        if (!EmojiHUD.sharedInstance.showing) {
            __showHUD = [NSTimer scheduledTimerWithTimeInterval:EmojiHUDHoldInterval target:self selector:@selector(_showHUD) userInfo:nil repeats:NO];
            [__showHUD retain];
        } else {
            [EmojiHUD.sharedInstance hide];
        }
    } else {
        if (EmojiHUD.sharedInstance.showing && !from)
            [EmojiHUD.sharedInstance hide];
        clearTimer();
    }
}

- (void)touchEnded:(id)arg1 {
    %orig;
    clearTimer();
}

- (void)dealloc {
    [EmojiHUD.sharedInstance hide];
    %orig;
}

%end

%hook UIKeyboardEmojiCategoryBar

- (void)touchesBegan:(id)arg1 withEvent:(id)arg2 {
    [EmojiHUD.sharedInstance hide];
    %orig;
}

%end
