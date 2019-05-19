#import "../EmojiLibrary/Header.h"
#import <UIKit/UIKeyboardPreferencesController.h>

%hook UIKeyboardEmojiCategoryPicker

- (NSString *)symbolForRow:(NSInteger)row {
    return ((UIKeyboardEmojiCategory *)[NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:row]).displaySymbol;
}

- (NSString *)titleForRow:(NSInteger)row {
    return ((UIKeyboardEmojiCategory *)[NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:row]).displayName;
}

%end

%hook UIKeyboardEmojiSplitCategoryPicker

- (NSString *)symbolForRow:(NSInteger)row {
    NSString *symbol = ((UIKeyboardEmojiCategory *)[NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:row]).displaySymbol;
    CGFloat rivenFactor = [[NSClassFromString(@"UIKeyboardPreferencesController") sharedPreferencesController] rivenSizeFactor:1.0];
    return [symbol stringByReplacingOccurrencesOfString:@".png" withString:rivenFactor < 1.0 ? @"_split-163r.png" : @"_split.png"];
}

%end