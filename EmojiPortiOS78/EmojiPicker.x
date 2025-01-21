#import <EmojiLibrary/Header.h>
#import <EmojiLibrary/PSEmojiUtilities.h>
#import <UIKit/UIKeyboardPreferencesController.h>

CGFloat scaleFactor = CATEGORIES_COUNT / 6.;

%hook UIKeyboardEmojiCategoryPicker

- (NSString *)symbolForRow:(NSInteger)row {
    return ((UIKeyboardEmojiCategory *)[NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:row]).displaySymbol;
}

- (NSString *)titleForRow:(NSInteger)row {
    return ((UIKeyboardEmojiCategory *)[NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:row]).displayName;
}

%end

#if __LP64__

%group iOS7Up

%hook UIKeyboardEmojiSplitCharacterPicker

- (id)initWithFrame:(CGRect)frame keyplane:(UIKBTree *)keyplane key:(UIKBTree *)key {
    CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height * scaleFactor);
    self = %orig(newFrame, keyplane, key);
    return self;
}

%end

%hook UIKeyboardEmojiSplitCategoryPicker

- (id)initWithFrame:(CGRect)frame keyplane:(UIKBTree *)keyplane key:(UIKBTree *)key {
    CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height * scaleFactor);
    self = %orig(newFrame, keyplane, key);
    return self;
}

- (NSString *)symbolForRow:(NSInteger)row {
    NSString *symbol = ((UIKeyboardEmojiCategory *)[NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:row]).displaySymbol;
    CGFloat rivenFactor = [[%c(UIKeyboardPreferencesController) sharedPreferencesController] rivenSizeFactor:1.0];
    return [symbol stringByReplacingOccurrencesOfString:@".png" withString:rivenFactor < 1.0 ? @"_split-163r.png" : @"_split.png"];
}

- (NSString *)titleForRow:(NSInteger)row {
    return ((UIKeyboardEmojiCategory *)[NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:row]).displayName;
}

%end

%end

#else

%group iOS6

%hook UIKeyboardEmojiPickerCategoryCell

- (UIFont *)symbolFont {
    CGFloat fontSize = [[%c(UIKeyboardPreferencesController) sharedPreferencesController] rivenSizeFactor:25.0];
    return [UIFont fontWithName:@"AppleColorEmoji" size:fontSize];
}

%end

%end

#endif

%ctor {
    %init;
#if __LP64__
    %init(iOS7Up);
#else
    %init(iOS6);
#endif
}