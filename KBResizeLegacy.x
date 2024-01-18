#import <EmojiLibrary/Header.h>
#import <PSHeader/Misc.h>
#import <UIKit/UIKeyboardImpl.h>
#import <UIKit/UIApplication+Private.h>
#import <version.h>
#import <dlfcn.h>
#import "../EmojiLayout/PSEmojiLayout.h"

extern NSString *UIKeyboardGetCurrentInputMode();

NSString *keyboardName() {
    UIKeyboardLayoutStar *layout = [UIKeyboardImpl.activeInstance _layout];
    return layout.keyplane.name;
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
    CGSize newSize = [%c(UIKeyboardImpl) isSplit] ? size
        : [UIKeyboardImpl keyboardSizeForInterfaceOrientation:[[UIApplication sharedApplication] _frontMostAppOrientation]];
    %orig(newSize);
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
    if (containsString(name, @"Emoji")) {
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
        for (UIKBShape *shape in Emoji_Control_Geometry_List.subtrees) {
            modifyBar(shape, scrollViewHeight, barHeight);
        }
    }
}

%group iOS70

%hook TIKeyboardFactory

- (UIKBTree *)keyboardWithName:(NSString *)name inCache:(id)cache {
    UIKBTree *keyboard = %orig;
    modifyKeyboard(keyboard, name);
    return keyboard;
}

%end

%end

%group iOS6

%hook TIKeyboardFactory

- (UIKBTree *)keyboardWithName:(NSString *)name {
    UIKBTree *keyboard = %orig;
    modifyKeyboard(keyboard, name);
    return keyboard;
}

%end

%hook UIKeyboardEmojiCategoryBar_iPad

- (id)initWithFrame:(CGRect)frame keyboard:(UIKBTree *)keyboard key:(UIKBTree *)key state:(int)state {
    UIKBShape *shape = key.shape;
    if (shape) {
        CGFloat height = [SoftPSEmojiLayout scrollViewHeight:keyboard.name];
        CGFloat height2 = [SoftPSEmojiLayout barHeight:keyboard.name];
        CGRect newFrame = CGRectMake(shape.frame.origin.x, height, shape.frame.size.width, height2);
        shape.frame = newFrame;
        key.shape = shape;
        frame = CGRectMake(shape.frame.origin.x, height, shape.frame.size.width, height2);
    }
    self = %orig(frame, keyboard, key, state);
    return self;
}

%end

%hook UIKeyboardEmojiScrollView

- (id)initWithFrame:(CGRect)frame keyboard:(UIKBTree *)keyboard key:(UIKBTree *)key state:(int)state {
    NSString *keyboardName = keyboard.name;
    if (key && [keyboardName rangeOfString:@"Emoji"].location != NSNotFound && [key.name isEqualToString:@"Emoji-InputView-Key"]) {
        UIKBShape *shape2 = key.shape;
        CGFloat height = [SoftPSEmojiLayout scrollViewHeight:keyboardName];
        CGRect newFrame2 = CGRectMake(shape2.frame.origin.x, shape2.frame.origin.y, shape2.frame.size.width, height);
        shape2.frame = newFrame2;
        CGRect paddedFrame2 = CGRectMake(shape2.paddedFrame.origin.x, shape2.paddedFrame.origin.y, shape2.paddedFrame.size.width, height);
        shape2.paddedFrame = paddedFrame2;
        key.shape = shape2;
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    }
    return %orig(frame, keyboard, key, state);
}

%end

%end

%ctor {
    if (IS_IOS_OR_NEWER(iOS_7_1))
        return;
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/TextInput.framework/TextInput"), RTLD_NOW);
    %init;
    if (IS_IOS_OR_NEWER(iOS_7_0)) {
        %init(iOS70);
    } else {
        %init(iOS6);
    }
}
