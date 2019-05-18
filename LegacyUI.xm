#import "../EmojiLibrary/Header.h"
#import "../PSHeader/Misc.h"
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIKeyboardImpl.h>

extern NSString *UIKBEmojiDivider;
extern NSString *UIKBEmojiDarkDivider;
extern NSString *UIKBEmojiSelectedDivider;

CGFloat (*UIKBKeyboardDefaultLandscapeWidth)();

static NSString *icons[] = { 
    @"🕘", @"😀", @"🐻", @"🌇", @"💡", @"🔣", @"⚽️", @"🍔", @"🏳"
};

UIImage *egImage(CGRect frame, NSString *imageName, BOOL pressed) {
    return [NSClassFromString(@"UIKeyboardEmojiGraphics") imageWithRect:frame name:imageName pressed:pressed];
}

NSMutableArray <UIImage *> *emojiCategoryBarImages(CGRect frame, BOOL pressed) {
    NSMutableArray <UIImage *> *array = [NSMutableArray array];
    [array addObject:egImage(frame, @"categoryRecents", pressed)];
    [array addObject:egImage(frame, @"categoryPeople", pressed)];
    [array addObject:egImage(frame, @"categoryNature", pressed)];
    [array addObject:egImage(frame, @"categoryFoodAndDrink", pressed)];
    [array addObject:egImage(frame, @"categoryActivity", pressed)];
    [array addObject:egImage(frame, @"categoryPlaces", pressed)];
    [array addObject:egImage(frame, @"categoryObjects", pressed)];
    [array addObject:egImage(frame, @"categorySymbols", pressed)];
    [array addObject:egImage(frame, @"categoryFlags", pressed)];
    return array;
}

%hook UIKeyboardEmojiCategoryBar_iPhone

- (void)layoutSubviews {
    %orig;
    for (UIImageView *divider in MSHookIvar<NSMutableArray *>(self, "_dividerViews"))
        divider.frame = CGRectMake(divider.frame.origin.x - 1.15, divider.frame.origin.y, divider.frame.size.width, divider.frame.size.height);
    for (UIImageView *segment in MSHookIvar<NSMutableArray *>(self, "_segmentViews"))
        segment.frame = CGRectMake(segment.frame.origin.x - 1.15, segment.frame.origin.y, segment.frame.size.width, segment.frame.size.height);
}

- (void)updateSegmentImages {
    NSMutableArray <UIView *> *segmentViews(MSHookIvar<NSMutableArray *>(self, "_segmentViews"));
    for (UIView *segment in segmentViews)
        [segment removeFromSuperview];
    NSMutableArray <UIView *> *dividerViews(MSHookIvar<NSMutableArray *>(self, "_dividerViews"));
    for (UIView *divider in dividerViews)
        [divider removeFromSuperview];
    [self releaseImagesAndViews];
    NSUInteger numberOfCategories = [NSClassFromString(@"UIKeyboardEmojiCategory") numberOfCategories];
    CGRect barFrame = self.frame;
    CGFloat dividerWidth = 1.0;
    CGFloat barWidth = barFrame.size.width;
    barFrame.size.width = (barWidth - (numberOfCategories + 1) * dividerWidth) / numberOfCategories;
    NSArray <UIImage *> *unselectedImages(MSHookIvar<NSArray *>(self, "_unselectedImages"));
    [unselectedImages release];
    NSArray <UIImage *> *selectedImages(MSHookIvar<NSArray *>(self, "_selectedImages"));
    [selectedImages release];
    MSHookIvar<NSArray *>(self, "_unselectedImages") = [emojiCategoryBarImages(barFrame, NO) retain];
    MSHookIvar<NSArray *>(self, "_selectedImages") = [emojiCategoryBarImages(barFrame, YES) retain];
    NSInteger additionalDivider = 0;
    CGFloat barHeight = barFrame.size.height;
    CGPoint origin = barFrame.origin;
    MSHookIvar<UIImage *>(self, "_plainDivider") = [egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiDivider, NO) retain];
    MSHookIvar<UIImage *>(self, "_darkDivider") = [egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiDarkDivider, NO) retain];
    MSHookIvar<UIImage *>(self, "_selectedDivider") = [egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiSelectedDivider, NO) retain];
    NSInteger orientation = [[UIApplication sharedApplication] _frontMostAppOrientation];
    if (!IS_IPAD && ((UIKBKeyboardDefaultLandscapeWidth() > 480.0) || (orientation == 3 || orientation == 4)))
        additionalDivider = 1;
    NSUInteger unselectedImagesCount = [MSHookIvar<NSArray *>(self, "_unselectedImages") count];
    MSHookIvar<NSInteger>(self, "_total") = unselectedImagesCount;
    MSHookIvar<NSInteger>(self, "_dividerTotal") = unselectedImagesCount + additionalDivider;
    MSHookIvar<NSMutableArray *>(self, "_segmentViews") = [[NSMutableArray alloc] initWithCapacity:MSHookIvar<NSInteger>(self, "_total")];
    MSHookIvar<NSMutableArray *>(self, "_dividerViews") = [[NSMutableArray alloc] initWithCapacity:MSHookIvar<NSInteger>(self, "_dividerTotal") + 1];
    if (MSHookIvar<NSInteger>(self, "_total")) {
        NSUInteger i = 0;
        do {
            UIImageView *unselectedImageView = [[UIImageView alloc] initWithImage:MSHookIvar<NSArray *>(self, "_unselectedImages")[i]];
            [self addSubview:unselectedImageView];
            [MSHookIvar<NSMutableArray *>(self, "_segmentViews") insertObject:unselectedImageView atIndex:i];
            [unselectedImageView release];
        } while (++i < MSHookIvar<NSInteger>(self, "_total"));
    }
    NSUInteger dividerCount = MSHookIvar<NSInteger>(self, "_dividerTotal");
    if (dividerCount) {
        NSUInteger j = 0;
        do {
            UIImage *dividerImage = (j && j < dividerCount) ? MSHookIvar<UIImage *>(self, "_plainDivider") : MSHookIvar<UIImage *>(self, "_darkDivider");
            UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:dividerImage];
            [self addSubview:dividerImageView];
            [MSHookIvar<NSMutableArray *>(self, "_dividerViews") insertObject:dividerImageView atIndex:j];
            [dividerImageView release];
        } while (++j - 1 < dividerCount);
    }
    [self updateSegmentAndDividers:MSHookIvar<int>(self, "_selected")];
}

%end

%hook UIKeyboardEmojiGraphics

- (UIImage *)categoryRecentsGenerator:(id)pressed {
    return [self categoryWithSymbol:icons[0] pressed:pressed];
}

- (UIImage *)categoryPeopleGenerator:(id)pressed {
    return [self categoryWithSymbol:icons[1] pressed:pressed];
}

- (UIImage *)categoryNatureGenerator:(id)pressed {
    return [self categoryWithSymbol:icons[2] pressed:pressed];
}

- (UIImage *)categoryPlacesGenerator:(id)pressed {
    return [self categoryWithSymbol:icons[3] pressed:pressed];
}

- (UIImage *)categoryObjectsGenerator:(id)pressed {
    return [self categoryWithSymbol:icons[4] pressed:pressed];
}

- (UIImage *)categorySymbolsGenerator:(id)pressed {
    return [self categoryWithSymbol:icons[5] pressed:pressed];
}

%new
- (UIImage *)categoryActivityGenerator:(id)pressed {
    return [self categoryWithSymbol:icons[6] pressed:pressed];
}

%new
- (UIImage *)categoryFoodAndDrinkGenerator:(id)pressed {
    return [self categoryWithSymbol:icons[7] pressed:pressed];
}

%new
- (UIImage *)categoryFlagsGenerator:(id)pressed {
    return [self categoryWithSymbol:icons[8] pressed:pressed];
}

%end

%hook UIKeyboardEmojiCategoryController

+ (Class)classForCategoryControl {
    if ([%c(UIKeyboardImpl) isSplit])
        return %c(UIKeyboardEmojiSplitCategoryPicker);
    Class clazz = %orig;
    return clazz == %c(UIKeyboardEmojiCategoryBar_iPad) ? %c(UIKeyboardEmojiCategoryBar_iPhone) : clazz;
}

%end

%ctor {
    MSImageRef ref = MSGetImageByName(realPath2(@"/System/Library/Frameworks/UIKit.framework/UIKit"));
    UIKBKeyboardDefaultLandscapeWidth = (CGFloat (*)())MSFindSymbol(ref, "_UIKBKeyboardDefaultLandscapeWidth");
    %init;
}
