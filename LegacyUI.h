#import "../EmojiLibrary/Header.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKBTree.h>

extern "C" {
    void CGContextResetCTM(CGContextRef);

    void UIKBRectsSetFrame(UIKBRectsRef, CGRect);
    void UIKBRectsSetDisplayFrame(UIKBRectsRef, CGRect);
    void UIKBRectsSetPaddedFrame(UIKBRectsRef, CGRect);
    void UIKBRectsRelease(UIKBRectsRef);

    CGColorRef UIKBGetNamedColor(CFStringRef);
    CGColorRef UIKBColorCreate(int, int, int, CGFloat);
    CGGradientRef UIKBCreateTwoColorLinearGradient(CGColorRef, CGColorRef);

    CGFloat UIKBScale();

    UIKBRectsRef UIKBRectsCreate(UIKBTree *keyboard, UIKBTree *key);
}