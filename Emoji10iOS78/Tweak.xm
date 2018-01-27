#import "../../EmojiLibrary/PSEmojiUtilities.h"
#import "../Header.h"
#import "../EmojiHUD.h"

%hook UIKeyboardEmoji

%property(assign) BOOL supportsSkin;

%end

%hook UIKeyboardEmojiCategoryPicker

- (NSString *)symbolForRow: (NSInteger)row {
    return ((UIKeyboardEmojiCategory *)[NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:row]).displaySymbol;
}

- (NSString *)titleForRow:(NSInteger)row {
    return ((UIKeyboardEmojiCategory *)[NSClassFromString(@"UIKeyboardEmojiCategory") categoryForType:row]).displayName;
}

%end

%hook UIKeyboardEmojiCategory

static NSMutableArray <UIKeyboardEmojiCategory *> *_categories;

+ (NSInteger)numberOfCategories {
    return CATEGORIES_COUNT;
}

+ (NSMutableArray <UIKeyboardEmojiCategory *> *)categories {
    if (_categories == nil) {
        NSInteger count = [self numberOfCategories];
        NSMutableArray <UIKeyboardEmojiCategory *> *_array = [NSMutableArray arrayWithCapacity:count];
        _categories = [_array retain];
        PSEmojiCategory categoryType = 0;
        do {
            UIKeyboardEmojiCategory *category = [[[NSClassFromString(@"UIKeyboardEmojiCategory") alloc] init] autorelease];
            category.categoryType = categoryType;
            [_categories addObject:category];
        } while (++categoryType != count);
    }
    return _categories;
}

- (void)releaseCategories {
    %orig;
    [_categories removeAllObjects];
}

- (NSString *)displaySymbol {
    PSEmojiCategory categoryType = self.categoryType;
    if (categoryType < CATEGORIES_COUNT)
        return extraIcons()[categoryType];
    return %orig;
}

+ (UIKeyboardEmojiCategory *)categoryForType:(PSEmojiCategory)categoryType {
    if (categoryType > [self numberOfCategories])
        return nil;
    NSArray <UIKeyboardEmojiCategory *> *categories = [self categories];
    UIKeyboardEmojiCategory *categoryForType = categories[categoryType];
    NSArray <UIKeyboardEmoji *> *emojiForType = categoryForType.emoji;
    if (emojiForType.count)
        return categoryForType;
    NSArray <NSString *> *emojiArray = [PSEmojiUtilities PrepolulatedEmoji];
    switch (categoryType) {
        case IDXPSEmojiCategoryRecent: {
            NSMutableArray <UIKeyboardEmoji *> *recents = [self emojiRecentsFromPreferences];
            if (recents) {
                categoryForType.emoji = recents;
                return categoryForType;
            }
            break;
        }
        case IDXPSEmojiCategoryPeople:
            emojiArray = [PSEmojiUtilities PeopleEmoji];
            break;
        case IDXPSEmojiCategoryNature:
            emojiArray = [PSEmojiUtilities NatureEmoji];
            break;
        case IDXPSEmojiCategoryFoodAndDrink:
            emojiArray = [PSEmojiUtilities FoodAndDrinkEmoji];
            break;
        case IDXPSEmojiCategoryActivity:
            emojiArray = [PSEmojiUtilities ActivityEmoji];
            break;
        case IDXPSEmojiCategoryTravelAndPlaces:
            emojiArray = [PSEmojiUtilities TravelAndPlacesEmoji];
            break;
        case IDXPSEmojiCategoryObjects:
            emojiArray = [PSEmojiUtilities ObjectsEmoji];
            break;
        case IDXPSEmojiCategorySymbols:
            emojiArray = [PSEmojiUtilities SymbolsEmoji];
            break;
        case IDXPSEmojiCategoryFlags:
            emojiArray = [PSEmojiUtilities FlagsEmoji];
            break;
    }
    NSMutableArray <UIKeyboardEmoji *> *_emojiArray = [NSMutableArray arrayWithCapacity:emojiArray.count];
    for (NSString *emojiString in emojiArray)
        [PSEmojiUtilities addEmoji:_emojiArray emojiString:emojiString];
    categoryForType.emoji = _emojiArray;
    return categoryForType;
}

%new
+ (BOOL)emojiString: (NSString *)emojiString inGroup: (NSArray <NSString *> *)group {
    return [PSEmojiUtilities emojiString:emojiString inGroup:group];
}

+ (NSUInteger)hasVariantsForEmoji:(NSString *)emojiString {
    return [PSEmojiUtilities hasVariantsForEmoji:emojiString];
}

%end

%ctor {
    %init;
}
