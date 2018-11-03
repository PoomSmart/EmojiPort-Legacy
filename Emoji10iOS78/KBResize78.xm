#define NO_EXTRA_ICONS
#import "../../EmojiLibrary/Header.h"
#import "../../EmojiLayout/PSEmojiLayout.h"
#import "../Header.h"
#import <UIKit/UIKBRenderTraits.h>
#import <UIKit/UIKBScreenTraits.h>
#import <UIKit/UIKeyboardImpl.h>
#import <UIKit/UIKeyboard.h>
#import <substrate.h>

extern "C" NSString *UIKeyboardGetCurrentInputMode();
NSString *(*UIKeyboardGetKBStarName8)(NSString *name, UIKBScreenTraits *traits, NSInteger type, NSInteger bias);
NSString *(*UIKeyboardGetKBStarName7)(NSString *name, UIKBScreenTraits *traits, NSInteger type);
NSArray <NSString *> *extraIcons();

void aHook(UIKeyboardEmojiCategoryBar *self, UIKBTree *key) {
    UIKBTree *_key = MSHookIvar<UIKBTree *>(self, "m_key");
    [key.subtrees removeAllObjects];
    NSArray <UIKeyboardEmojiCategory *> *categories = [NSClassFromString(@"UIKeyboardEmojiCategory") categories];
    NSInteger count = categories.count;
    NSMutableArray <UIKBTree *> *keys = [NSMutableArray arrayWithCapacity:count];
    NSUInteger index = 0;
    do {
        UIKBTree *emojiKey = [[UIKBTree alloc] initWithType:8];
        UIKeyboardEmojiCategory *category = categories[index];
        NSInteger categoryType = category.categoryType;
        if (categoryType < count) {
            emojiKey.displayString = extraIcons()[categoryType];
            [keys addObject:[emojiKey autorelease]];
        }
    } while (++index < count);
    [_key.subtrees addObjectsFromArray:keys];
    key = _key;
}

%hook UIKBRenderFactoryEmoji_iPhone

- (UIKBRenderTraits *)_traitsForKey:(UIKBTree *)key onKeyplane:(UIKBTree *)keyplane {
    UIKBRenderTraits *traits = %orig;
    if (traits) {
        NSString *keyName = key.name;
        NSString *keyplaneName = keyplane.name;
        CGFloat paddedDeltaPosX, paddedDeltaPosY, paddedDeltaWidth, paddedDeltaHeight;
        CGRect oldPaddedFrame, correctFrame;
        CGFloat height2 = [SoftPSEmojiLayout barHeight:keyplaneName];
        if ([keyName isEqualToString:@"Emoji-Category-Control-Key"]) {
            NSArray <UIKBRenderGeometry *> *_geometries = traits.variantGeometries;
            NSMutableArray <UIKBRenderGeometry *> *geometries = [NSMutableArray arrayWithArray:_geometries];
            NSUInteger count = geometries.count;
            if (count > 1) {
                CGRect barFrame = key.frame;
                CGFloat barWidth = barFrame.size.width;
                CGFloat correctGeometryWidth = barWidth / count;
                CGFloat startX = _geometries[0].frame.origin.x;
                for (NSUInteger index = 0; index < count; index++) {
                    UIKBRenderGeometry *geometry = _geometries[index];
                    CGFloat correctGeometryPosX = startX + correctGeometryWidth*index;
                    paddedDeltaPosX = geometry.paddedFrame.origin.x - geometry.frame.origin.x;
                    paddedDeltaPosY = geometry.paddedFrame.origin.y - geometry.frame.origin.y;
                    paddedDeltaWidth = geometry.paddedFrame.size.width - geometry.frame.size.width;
                    paddedDeltaHeight = geometry.paddedFrame.size.height - geometry.frame.size.height;
                    correctFrame = CGRectMake(correctGeometryPosX, geometry.frame.origin.y, correctGeometryWidth, height2);
                    geometry.frame = correctFrame;
                    geometry.displayFrame = correctFrame;
                    CGRect symbolFrame = geometry.symbolFrame;
                    CGRect correctSymbolFrame = CGRectMake(correctGeometryPosX, symbolFrame.origin.y, correctGeometryWidth, height2);
                    geometry.symbolFrame = correctSymbolFrame;
                    geometry.paddedFrame = correctFrame;
                    oldPaddedFrame = geometry.paddedFrame;
                    geometry.paddedFrame = CGRectMake(oldPaddedFrame.origin.x + paddedDeltaPosX, oldPaddedFrame.origin.y + paddedDeltaPosY, oldPaddedFrame.size.width + paddedDeltaWidth, oldPaddedFrame.size.height + paddedDeltaHeight);
                    geometries[index] = geometry;
                }
                traits.variantGeometries = geometries;
            }
        } else if (isTargetKey(keyName)) {
            UIKBRenderGeometry *inputGeometry = traits.geometry;
            if (inputGeometry && key.state != 16) {
                CGFloat height = [SoftPSEmojiLayout scrollViewHeight:keyplaneName];
                CGRect frame = inputGeometry.frame;
                paddedDeltaPosX = inputGeometry.paddedFrame.origin.x - frame.origin.x;
                paddedDeltaPosY = inputGeometry.paddedFrame.origin.y - frame.origin.y;
                paddedDeltaWidth = inputGeometry.paddedFrame.size.width - frame.size.width;
                paddedDeltaHeight = inputGeometry.paddedFrame.size.height - frame.size.height;
                correctFrame = CGRectMake(frame.origin.x, height, frame.size.width, height2);
                inputGeometry.displayFrame = correctFrame;
                inputGeometry.symbolFrame = correctFrame;
                inputGeometry.paddedFrame = correctFrame;
                oldPaddedFrame = inputGeometry.paddedFrame;
                inputGeometry.paddedFrame = CGRectMake(oldPaddedFrame.origin.x + paddedDeltaPosX, oldPaddedFrame.origin.y + paddedDeltaPosY, oldPaddedFrame.size.width + paddedDeltaWidth, oldPaddedFrame.size.height + paddedDeltaHeight);
                inputGeometry.frame = correctFrame;
                traits.geometry = inputGeometry;
            }
        }
    }
    return traits;
}

%end

%hook UIKBKeyView

%new
- (void)emoji83_positionFixForKeyplane:(UIKBTree *)keyplane key:(UIKBTree *)key {
    NSString *keyName = key.name;
    NSString *keyplaneName = keyplane.name;
    if (isTargetKey(keyName) && [keyplaneName rangeOfString:@"Emoji"].location != NSNotFound) {
        CGRect frame = key.frame;
        CGFloat height = [SoftPSEmojiLayout scrollViewHeight:keyplaneName];
        CGFloat height2 = [SoftPSEmojiLayout barHeight:keyplaneName];
        CGRect newFrame = CGRectMake(frame.origin.x, height, frame.size.width, height2);
        if (key.state != 16) {
            key.frame = newFrame;
            UIKBShape *shape = key.shape;
            CGRect paddedFrame = shape.paddedFrame;
            CGRect newPaddedFrame = CGRectMake(paddedFrame.origin.x, height, paddedFrame.size.width, height2);
            shape.frame = newFrame;
            shape.paddedFrame = newPaddedFrame;
            key.shape = shape;
        }
    }
}

- (id)initWithFrame:(CGRect)frame keyplane:(UIKBTree *)keyplane key:(UIKBTree *)key {
    [self emoji83_positionFixForKeyplane:keyplane key:key];
    self = %orig(frame, keyplane, key);
    return self;
}

- (void)updateForKeyplane:(UIKBTree *)keyplane key:(UIKBTree *)key {
    %orig;
    [self emoji83_positionFixForKeyplane:keyplane key:key];
}

%end

%hook UIKeyboardEmojiCategoryBar

- (id)initWithFrame:(CGRect)frame keyplane:(UIKBTree *)keyplane key:(UIKBTree *)key {
    UIKBShape *shape = key.shape;
    if (shape) {
        CGFloat height = [SoftPSEmojiLayout scrollViewHeight:keyplane.name];
        CGFloat height2 = [SoftPSEmojiLayout barHeight:keyplane.name];
        CGRect newFrame = CGRectMake(shape.frame.origin.x, height, shape.frame.size.width, height2);
        shape.frame = newFrame;
        key.shape = shape;
        frame = CGRectMake(shape.frame.origin.x, height, shape.frame.size.width, height2);
    }
    self = %orig(frame, keyplane, key);
    aHook(self, key);
    return self;
}

%end

%hook UIKeyboardEmojiScrollView

- (id)initWithFrame:(CGRect)frame keyplane:(UIKBTree *)keyplane key:(UIKBTree *)key {
    NSString *keyplaneName = keyplane.name;
    if (key && [keyplaneName rangeOfString:@"Emoji"].location != NSNotFound && [key.name isEqualToString:@"Emoji-InputView-Key"]) {
        UIKBShape *shape2 = key.shape;
        CGFloat height = [SoftPSEmojiLayout scrollViewHeight:keyplaneName];
        CGRect newFrame2 = CGRectMake(shape2.frame.origin.x, shape2.frame.origin.y, shape2.frame.size.width, height);
        shape2.frame = newFrame2;
        CGRect paddedFrame2 = CGRectMake(shape2.paddedFrame.origin.x, shape2.paddedFrame.origin.y, shape2.paddedFrame.size.width, height);
        shape2.paddedFrame = paddedFrame2;
        key.shape = shape2;
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    }
    return %orig(frame, keyplane, key);
}

%end

%group iOS8

%hook UIKeyboardImpl

CGSize hookSize(CGSize size) {
    Class layoutClass = [UIKeyboardImpl layoutClassForCurrentInputMode];
    if (layoutClass == NSClassFromString(@"UIKeyboardLayoutStar")) {
        UIKBScreenTraits *screenTraits = [NSClassFromString(@"UIKBScreenTraits") traitsWithScreen:[UIKeyboardImpl keyboardScreen] orientation:[[[UIKeyboardImpl activeInstance] _layout] orientation]];
        NSString *name = UIKeyboardGetKBStarName8(UIKeyboardGetCurrentInputMode(), screenTraits, 0, 0);
        UIKBTree *tree = [layoutClass keyboardFromFactoryWithName:name screen:[UIKeyboardImpl keyboardScreen]];
        if (tree && [name rangeOfString:@"Emoji"].location != NSNotFound) {
            UIKBShape *shape = tree.shape;
            CGFloat height = [SoftPSEmojiLayout keyboardHeight:name];
            CGRect newFrame = CGRectMake(shape.frame.origin.x, shape.frame.origin.y, shape.frame.size.width, height);
            return newFrame.size;
        }
    }
    return size;
}

- (void)_resizeForKeyplaneSize:(CGSize)size splitWidthsChanged:(BOOL)changed {
    %orig(hookSize(size), changed);
}

%end

%hook UIKeyboardLayoutStar

- (void)_resizeForKeyplaneSize:(CGSize)size splitWidthsChanged:(BOOL)changed {
    %orig(hookSize(size), changed);
}

%end

%end

%group iOS71

%hook UIKeyboardLayoutStar

- (void)resizeForKeyplaneSize:(CGSize)size {
    NSInteger orientation = [[NSClassFromString(@"UIKeyboard") activeKeyboard] interfaceOrientation];
    UIKBScreenTraits *screenTraits = [NSClassFromString(@"UIKBScreenTraits") traitsWithScreen:[UIKeyboardImpl keyboardScreen] orientation:orientation];
    [screenTraits setOrientationKey:[UIKeyboardImpl orientationKeyForOrientation:orientation]];
    NSString *name = UIKeyboardGetKBStarName7(UIKeyboardGetCurrentInputMode(), screenTraits, 0);
    UIKBTree *tree = [NSClassFromString(@"UIKeyboardLayoutStar") keyboardFromFactoryWithName:name screen:[UIKeyboardImpl keyboardScreen]];
    if (tree && [name rangeOfString:@"Emoji"].location != NSNotFound) {
        UIKBShape *shape = tree.shape;
        CGFloat height = [SoftPSEmojiLayout keyboardHeight:name];
        CGRect newFrame = CGRectMake(shape.frame.origin.x, shape.frame.origin.y, shape.frame.size.width, height);
        %orig(newFrame.size);
        return;
    }
    %orig(size);
}

%end

%end

%ctor {
    MSImageRef ref = MSGetImageByName(realPath2(@"/System/Library/Frameworks/UIKit.framework/UIKit"));
    if (isiOS8Up) {
        UIKeyboardGetKBStarName8 = (NSString *(*)(NSString *, UIKBScreenTraits *, NSInteger, NSInteger))MSFindSymbol(ref, "_UIKeyboardGetKBStarName");
        %init(iOS8);
    } else {
        if (isiOS71Up) {
            UIKeyboardGetKBStarName7 = (NSString *(*)(NSString *, UIKBScreenTraits *, NSInteger))MSFindSymbol(ref, "_UIKeyboardGetKBStarName");
            %init(iOS71);
        }
    }
    %init;
}
