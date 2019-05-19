#import "../EmojiLibrary/Header.h"
#import "../EmojiLayout/PSEmojiLayout.h"
#import "../PSHeader/Misc.h"
#import <UIKit/UIKeyboardImpl.h>
#import <UIKit/UIApplication+Private.h>

extern "C" NSString *UIKeyboardGetCurrentInputMode();

NSString *keyboardName() {
    return [UIKeyboardImpl.activeInstance _layout].keyplane.name;
}

BOOL isEmojiInput() {
    return [UIKeyboardGetCurrentInputMode() isEqualToString:@"emoji@sw=Emoji"];
}

%hook UIKeyboardImpl

+ (CGSize)sizeForInterfaceOrientation:(NSInteger)orientation {
    CGSize size = %orig;
    if (isEmojiInput())
        size.height = [SoftPSEmojiLayout keyboardHeight:keyboardName()];
    return size;
}

+ (CGSize)defaultSizeForInterfaceOrientation:(NSInteger)orientation {
    CGSize size = %orig;
    if (isEmojiInput())
        size.height = [SoftPSEmojiLayout keyboardHeight:keyboardName()];
    return size;
}

+ (CGSize)keyboardSizeForInterfaceOrientation:(NSInteger)orientation {
    CGSize size = %orig;
    if (isEmojiInput())
        size.height = [SoftPSEmojiLayout keyboardHeight:keyboardName()];
    return size;
}

%end

%hook UIKeyboardLayoutStar

- (void)resizeForKeyplaneSize:(CGSize)size {
    %orig([UIKeyboardImpl keyboardSizeForInterfaceOrientation:[[UIApplication sharedApplication] _frontMostAppOrientation]]);
}

%end

void modifyScroll(UIKBShape *shape, CGFloat height) {
    shape.frame = CGRectMake(shape.frame.origin.x, shape.frame.origin.y, shape.frame.size.width, height);
    shape.paddedFrame = CGRectMake(shape.paddedFrame.origin.x, shape.paddedFrame.origin.y, shape.paddedFrame.size.width, height);
}

void modifyBar(UIKBShape *shape, CGFloat scrollViewHeight, CGFloat barHeight) {
    shape.frame = CGRectMake(shape.frame.origin.x, scrollViewHeight, shape.frame.size.width, barHeight);
    shape.paddedFrame = CGRectMake(shape.paddedFrame.origin.x, scrollViewHeight, shape.paddedFrame.size.width, barHeight);
}

void modifyKeyboard(UIKBTree *keyboard, NSString *name) {
    if ([name rangeOfString:@"Emoji"].location != NSNotFound) {
        CGFloat keyboardHeight = [SoftPSEmojiLayout keyboardHeight:name];
        CGFloat barHeight = [SoftPSEmojiLayout barHeight:name];
        CGFloat scrollViewHeight = keyboardHeight - barHeight;
        UIKBShape *kbShape = (UIKBShape *)(keyboard.properties[@"KBshape"]);
        if (kbShape)
            kbShape.frame = CGRectMake(kbShape.frame.origin.x, kbShape.frame.origin.y, kbShape.frame.size.width, keyboardHeight);
        UIKBTree *subtree = keyboard.subtrees[0];
        UIKBTree *Emoji_InputView_Keylayout = subtree.subtrees[0];
        UIKBTree *Emoji_InputView_Keys_GeometrySet = Emoji_InputView_Keylayout.subtrees[1];
        UIKBTree *Emoji_InputView_Geometry_List = Emoji_InputView_Keys_GeometrySet.subtrees[0];
        UIKBShape *Emoji_InputView_Geometry_List_shape = Emoji_InputView_Geometry_List.subtrees[0];
        modifyScroll(Emoji_InputView_Geometry_List_shape, scrollViewHeight);
        UIKBTree *Emoji_Category_Control_Keylayout = subtree.subtrees[1];
        UIKBTree *Emoji_Category_Control_Keys_GeometrySet = Emoji_Category_Control_Keylayout.subtrees[1];
        UIKBTree *Emoji_Category_Control_Geometry_List = Emoji_Category_Control_Keys_GeometrySet.subtrees[0];
        UIKBShape *Emoji_Category_Control_Geometry_List_shape = Emoji_Category_Control_Geometry_List.subtrees[0];
        modifyBar(Emoji_Category_Control_Geometry_List_shape, scrollViewHeight, barHeight);
        UIKBTree *Emoji_Control_Keylayout = subtree.subtrees[2];
        UIKBTree *Emoji_Control_Keys_GeometrySet = Emoji_Control_Keylayout.subtrees[1];
        UIKBTree *Emoji_Control_Geometry_List = Emoji_Control_Keys_GeometrySet.subtrees[0];
        UIKBShape *Emoji_Control_Geometry_List_shape1 = Emoji_Control_Geometry_List.subtrees[0];
        UIKBShape *Emoji_Control_Geometry_List_shape2 = Emoji_Control_Geometry_List.subtrees[1];
        modifyBar(Emoji_Control_Geometry_List_shape1, scrollViewHeight, barHeight);
        modifyBar(Emoji_Control_Geometry_List_shape2, scrollViewHeight, barHeight);
    }
}

%hook TIKeyboardFactory

%group iOS70

- (UIKBTree *)keyboardWithName:(NSString *)name inCache:(id)cache {
    UIKBTree *keyboard = %orig;
    modifyKeyboard(keyboard, name);
    return keyboard;
}

%end

%group iOS6

- (UIKBTree *)keyboardWithName:(NSString *)name {
    UIKBTree *keyboard = %orig;
    modifyKeyboard(keyboard, name);
    return keyboard;
}

%end

%end

%ctor {
    if (isiOS71Up)
        return;
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/TextInput.framework/TextInput"), RTLD_LAZY);
    %init;
    if (isiOS70) {
        %init(iOS70);
    } else {
        %init(iOS6);
    }
}
