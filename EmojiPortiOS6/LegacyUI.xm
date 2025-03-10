#import <EmojiLibrary/PSEmojiUtilities.h>
#import <PSHeader/Misc.h>
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIKeyboardImpl.h>
#import <theos/IOSMacros.h>
#import <version.h>
#import "Global.h"
#import "LegacyUI.h"

extern NSString *UIKBEmojiDivider;
extern NSString *UIKBEmojiDarkDivider;
extern NSString *UIKBEmojiSelectedDivider;

void (*UIKBThemeSetFontSize)(UIKBThemeRef, CGFloat);
void (*UIKBThemeSetSymbolColor)(UIKBThemeRef, CGColorRef);
void (*UIKBThemeSetForegroundGradient)(UIKBThemeRef, CGGradientRef);
void (*UIKBThemeSetEtchColor)(UIKBThemeRef, CGColorRef);
void (*UIKBThemeSetEtchDY)(UIKBThemeRef, CGFloat);
void (*UIKBThemeRelease)(UIKBThemeRef);

void (*UIKBDrawEtchedSymbolString)(CGContextRef, NSString *, UIKBThemeRef, CGRect);
void (*UIKBDrawRoundRectKeyBackground)(CGContextRef, UIKBTree *, UIKBTree *, int, UIKBThemeRef, UIKBRectsRef);

CGContextRef (*UIKBCreateBitmapContextWithScale)(CGSize size, CGFloat scale);

CGFloat (*UIKBKeyboardDefaultLandscapeWidth)();

UIImage *egImage(CGRect frame, NSString *imageName, BOOL pressed) {
    return [%c(UIKeyboardEmojiGraphics) imageWithRect:frame name:imageName pressed:pressed];
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
    for (UIImageView *divider in [self valueForKey:@"_dividerViews"])
        divider.frame = CGRectMake(divider.frame.origin.x - 1.15, divider.frame.origin.y, divider.frame.size.width, divider.frame.size.height);
    for (UIImageView *segment in [self valueForKey:@"_segmentViews"])
        segment.frame = CGRectMake(segment.frame.origin.x - 1.15, segment.frame.origin.y, segment.frame.size.width, segment.frame.size.height);
}

- (void)updateSegmentImages {
    NSMutableArray <UIView *> *segmentViews([self valueForKey:@"_segmentViews"]);
    for (UIView *segment in segmentViews)
        [segment removeFromSuperview];
    NSMutableArray <UIView *> *dividerViews([self valueForKey:@"_dividerViews"]);
    for (UIView *divider in dividerViews)
        [divider removeFromSuperview];
    [self releaseImagesAndViews];
    NSUInteger numberOfCategories = [%c(UIKeyboardEmojiCategory) numberOfCategories];
    CGRect barFrame = self.frame;
    CGFloat dividerWidth = 1.0;
    CGFloat barWidth = barFrame.size.width;
    barFrame.size.width = (barWidth - (numberOfCategories + 1) * dividerWidth) / numberOfCategories;
    [self setValue:emojiCategoryBarImages(barFrame, NO) forKey:@"_unselectedImages"];
    [self setValue:emojiCategoryBarImages(barFrame, YES) forKey:@"_selectedImages"];
    int additionalDivider = 0;
    CGFloat barHeight = barFrame.size.height;
    CGPoint origin = barFrame.origin;
    [self setValue:egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiDivider, NO) forKey:@"_plainDivider"];
    [self setValue:egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiDarkDivider, NO) forKey:@"_darkDivider"];
    [self setValue:egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiSelectedDivider, NO) forKey:@"_selectedDivider"];
    NSInteger orientation = [[UIApplication sharedApplication] _frontMostAppOrientation];
    if (!IS_IPAD && ((UIKBKeyboardDefaultLandscapeWidth() > 480.0) || (orientation == 3 || orientation == 4)))
        additionalDivider = 1;
    NSArray <UIImage *> *currentUnselectedImages = [self valueForKey:@"_unselectedImages"];
    NSUInteger unselectedImagesCount = [currentUnselectedImages count];
    MSHookIvar<NSInteger>(self, "_total") = unselectedImagesCount;
    int dividerTotal = unselectedImagesCount + additionalDivider;
    MSHookIvar<NSInteger>(self, "_dividerTotal") = dividerTotal;
    [self setValue:[[NSMutableArray alloc] initWithCapacity:unselectedImagesCount] forKey:@"_segmentViews"];
    [self setValue:[[NSMutableArray alloc] initWithCapacity:dividerTotal + 1] forKey:@"_dividerViews"];
    int total = [[self valueForKey:@"_total"] intValue];
    if (total) {
        int i = 0;
        do {
            UIImageView *unselectedImageView = [[UIImageView alloc] initWithImage:currentUnselectedImages[i]];
            [self addSubview:unselectedImageView];
            [[self valueForKey:@"_segmentViews"] insertObject:unselectedImageView atIndex:i];
        } while (++i < total);
    }
    if (dividerTotal) {
        int j = 0;
        do {
            UIImage *dividerImage = (j && j < dividerTotal) ? [self valueForKey:@"_plainDivider"] : [self valueForKey:@"_darkDivider"];
            UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:dividerImage];
            [self addSubview:dividerImageView];
            [[self valueForKey:@"_dividerViews"] insertObject:dividerImageView atIndex:j];
        } while (++j - 1 < dividerTotal);
    }
    [self updateSegmentAndDividers:[[self valueForKey:@"_selected"] intValue]];
}

%end

%hook UIKeyboardEmojiGraphics

- (UIImage *)categoryKeyGenerator:(bool)pressed rect:(CGRect)rect {
    UIKBTree *protoKey = [self protoKeyWithDisplayString:@"!"];
    UIKBShape *shape = [[%c(UIKBShape) alloc] initWithGeometry:nil frame:rect paddedFrame:rect];
    protoKey.shape = shape;
    UIKBTree *protoKeyboard = [self protoKeyboard];
    int state = pressed ? 8 : 4;
    UIKBThemeRef theme = [self createProtoThemeForKey:protoKey keyboard:protoKeyboard state:state];
    CGFloat fontSize = [%c(UIKeyboardEmojiGraphics) isLandscape] ? 38.0 : 32.0;
    UIKBThemeSetFontSize(theme, fontSize);
    CGColorRef color = NULL;
    CGGradientRef gradient = NULL;
    if (pressed) {
        UIKBThemeSetSymbolColor(theme, UIKBGetNamedColor(CFSTR("UIKBColorWhite")));
        UIKBThemeSetEtchColor(theme, UIKBGetNamedColor(CFSTR("UIKBColorBlack_Alpha50")));
        UIKBThemeSetEtchDY(theme, -1.0);
        CGColorRef gradientEnd = UIKBGetNamedColor(CFSTR("UIKBColorKeyBlueRow1GradientEnd"));
        CGColorRef gradientStart = UIKBGetNamedColor(CFSTR("UIKBColorKeyBlueRow1GradientStart"));
        gradient = UIKBCreateTwoColorLinearGradient(gradientEnd, gradientStart);
        UIKBThemeSetForegroundGradient(theme, gradient);
    } else {
        color = UIKBColorCreate(69, 69, 85, 1.0);
        UIKBThemeSetSymbolColor(theme, color);
    }
    UIKBRectsRef rects = UIKBRectsCreate(protoKeyboard, protoKey);
    CGFloat scale = UIKBScale();
    CGContextRef ctx = UIKBCreateBitmapContextWithScale(rect.size, scale);
    CGContextSaveGState(ctx);
    CGContextResetCTM(ctx);
    CGAffineTransform t = CGAffineTransformMakeScale(scale, scale);
    CGContextConcatCTM(ctx, t);
    t.a = 1.0;
    t.b = 0.0;
    t.c = 0.0;
    t.d = -1.0;
    t.tx = 0.0;
    t.ty = rect.size.height;
    CGContextConcatCTM(ctx, t);
    CGRect frame = CGRectInset(protoKey.frame, 4.0, 4.0);
    UIKBRectsSetFrame(rects, frame);
    CGRect displayFrame = CGRectInset(protoKey.frame, 4.0, 4.0);
    UIKBRectsSetDisplayFrame(rects, displayFrame);
    CGRect paddedFrame = CGRectInset(protoKey.frame, 4.0, 4.0);
    UIKBRectsSetPaddedFrame(rects, paddedFrame);
    UIKBDrawRoundRectKeyBackground(ctx, protoKeyboard, protoKey, state, theme, rects);
    CGRect symbolRect = CGRectInset(rect, 4.0, 4.0);
    CGFloat d = symbolRect.size.width / CATEGORIES_COUNT;
    symbolRect.origin.x -= 4 * d; // FIXME: We should not need this line
    for (NSString *symbol in displaySymbolsAsGlyphs()) {
        CGContextSaveGState(ctx);
        UIKBDrawEtchedSymbolString(ctx, symbol, theme, symbolRect);
        CGContextRestoreGState(ctx);
        symbolRect.origin.x += d;
    }
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:scale orientation:0];
    CGContextRelease(ctx);
    CGImageRelease(cgImage);
    UIKBRectsRelease(rects);
    if (color)
        CGColorRelease(color);
    if (gradient)
        CGGradientRelease(gradient);
    UIKBThemeRelease(theme);
    return image;
}

- (UIImage *)categoryRecentsGenerator:(id)pressed {
    return [self categoryWithSymbol:displaySymbolsAsGlyphs()[0] pressed:pressed];
}

- (UIImage *)categoryPeopleGenerator:(id)pressed {
    return [self categoryWithSymbol:displaySymbolsAsGlyphs()[1] pressed:pressed];
}

- (UIImage *)categoryNatureGenerator:(id)pressed {
    return [self categoryWithSymbol:displaySymbolsAsGlyphs()[2] pressed:pressed];
}

- (UIImage *)categoryPlacesGenerator:(id)pressed {
    return [self categoryWithSymbol:displaySymbolsAsGlyphs()[3] pressed:pressed];
}

- (UIImage *)categoryObjectsGenerator:(id)pressed {
    return [self categoryWithSymbol:displaySymbolsAsGlyphs()[4] pressed:pressed];
}

- (UIImage *)categorySymbolsGenerator:(id)pressed {
    return [self categoryWithSymbol:displaySymbolsAsGlyphs()[5] pressed:pressed];
}

%new(@@:@)
- (UIImage *)categoryActivityGenerator:(id)pressed {
    return [self categoryWithSymbol:displaySymbolsAsGlyphs()[6] pressed:pressed];
}

%new(@@:@)
- (UIImage *)categoryFoodAndDrinkGenerator:(id)pressed {
    return [self categoryWithSymbol:displaySymbolsAsGlyphs()[7] pressed:pressed];
}

%new(@@:@)
- (UIImage *)categoryFlagsGenerator:(id)pressed {
    return [self categoryWithSymbol:displaySymbolsAsGlyphs()[8] pressed:pressed];
}

%end

%ctor {
    MSImageRef ref = MSGetImageByName(realPath2(@"/System/Library/Frameworks/UIKit.framework/UIKit"));
    UIKBKeyboardDefaultLandscapeWidth = (CGFloat (*)())MSFindSymbol(ref, "_UIKBKeyboardDefaultLandscapeWidth");
    UIKBThemeSetFontSize = (void (*)(UIKBThemeRef, CGFloat))MSFindSymbol(ref, "_UIKBThemeSetFontSize");
    UIKBThemeSetSymbolColor = (void (*)(UIKBThemeRef, CGColorRef))MSFindSymbol(ref, "_UIKBThemeSetSymbolColor");
    UIKBThemeSetForegroundGradient = (void (*)(UIKBThemeRef, CGGradientRef))MSFindSymbol(ref, "_UIKBThemeSetForegroundGradient");
    UIKBThemeSetEtchColor = (void (*)(UIKBThemeRef, CGColorRef))MSFindSymbol(ref, "_UIKBThemeSetEtchColor");
    UIKBThemeSetEtchDY = (void (*)(UIKBThemeRef, CGFloat))MSFindSymbol(ref, "_UIKBThemeSetEtchDY");
    UIKBThemeRelease = (void (*)(UIKBThemeRef))MSFindSymbol(ref, "_UIKBThemeRelease");
    UIKBDrawEtchedSymbolString = (void (*)(CGContextRef, NSString *, UIKBThemeRef, CGRect))MSFindSymbol(ref, "_UIKBDrawEtchedSymbolString");
    UIKBDrawRoundRectKeyBackground = (void (*)(CGContextRef, UIKBTree *, UIKBTree *, int, UIKBThemeRef, UIKBRectsRef))MSFindSymbol(ref, "_UIKBDrawRoundRectKeyBackground");
    UIKBCreateBitmapContextWithScale = (CGContextRef (*)(CGSize, CGFloat))MSFindSymbol(ref, "_UIKBCreateBitmapContextWithScale");
    %init;
}
