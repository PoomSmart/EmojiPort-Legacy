#import "../../EmojiLibrary/PSEmojiUtilities.h"
#import <CoreFoundation/CoreFoundation.h>
#import <CoreText/CoreText.h>
#import "../EmojiHUD.h"
#import "../Header.h"

CTFontRef emojiFont;

BOOL allowGlyphSet = YES;
BOOL fromTweak = NO;

void fixEmojiGlyph(UIKeyboardEmoji *emoji) {
    if (emoji == nil)
        return;
    NSString *emojiString = emoji.emojiString;
    NSUInteger stringLength = emojiString.length;
    if (stringLength == 0)
        return;
    fromTweak = YES;
    if (stringLength >= 4) {
        NSAttributedString *aStr = [[[NSAttributedString alloc] initWithString:emojiString attributes:@{ (NSString *)kCTFontAttributeName : (id)emojiFont }] autorelease];
        CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)aStr);
        if (line) {
            CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
            if (glyphRuns) {
                CTRunRef glyphRun = (CTRunRef)CFArrayGetValueAtIndex(glyphRuns, 0);
                if (glyphRun) {
                    NSUInteger glyphCount = CTRunGetGlyphCount(glyphRun);
                    const CGGlyph *glyphs2 = CTRunGetGlyphsPtr(glyphRun);
                    if (glyphs2 == NULL) {
                        size_t glyphsBufferSize = sizeof(CGGlyph) * glyphCount;
                        CGGlyph *glyphsBuffer = (CGGlyph *)malloc(glyphsBufferSize);
                        CTRunGetGlyphs(glyphRun, CFRangeMake(0, 0), glyphsBuffer);
                    }
                    if (glyphs2)
                        emoji.glyph = glyphs2[0];
                    CFRelease(glyphRun);
                }
                CFRelease(glyphRuns);
            }
        }
    } else {
        unichar characters[16] = {
            0
        };
        [emojiString getCharacters:characters range:NSMakeRange(0, stringLength)];
        size_t length = 0;
        while (characters[length])
            length++;
        CGGlyph glyphs[length];
        if (CTFontGetGlyphsForCharacters(emojiFont, characters, glyphs, length)) {
            CGGlyph g = emoji.glyph = glyphs[0];
            if (g >= 5 && g <= 16)
                emoji.glyph += 44;
            else if (g == 44)
                emoji.glyph = 48;
        }
    }
    if (stringEqual(emojiString, @"#️⃣"))
        emoji.glyph = 47;
    else if (emoji.glyph == 795 && stringLength >= 4)
        emoji.glyph = 796;
    fromTweak = NO;
}

%hook UIKeyboardEmoji

%property(assign) BOOL supportsSkin;

- (id)initWithString:(NSString *)emojiString {
    self = %orig;
    fixEmojiGlyph(self);
    return self;
}

- (void)setGlyph:(CGGlyph)glyph {
    if (!allowGlyphSet && !fromTweak)
        return;
    %orig;
}

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

+ (NSMutableArray <UIKeyboardEmoji *> *)getGlyphForRecents:(id)arg1 {
    allowGlyphSet = NO;
    NSMutableArray <UIKeyboardEmoji *> *orig = %orig;
    allowGlyphSet = YES;
    return orig;
}

+ (NSInteger)numberOfCategories {
    return CATEGORIES_COUNT;
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
            NSMutableArray *recents = [self emojiRecentsFromPreferences];
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

%end

%ctor {
    emojiFont = CTFontCreateWithName(CFSTR("AppleColorEmoji"), 12.0, NULL);
    %init;
}

%dtor {
    if (emojiFont)
        CFRelease(emojiFont);
}
