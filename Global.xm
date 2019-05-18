NSArray <NSString *> *extraIcons() {
    return @[@"emoji_recents.png", @"emoji_people.png", @"emoji_nature.png", @"emoji_food-and-drink.png", @"emoji_activity.png", @"emoji_travel-and-places.png", @"emoji_objects.png", @"emoji_objects-and-symbols.png", @"emoji_flags.png"];
}

BOOL isTargetKey(NSString *name) {
    return [name isEqualToString:@"Delete-Key"] || [name isEqualToString:@"International-Key"] || [name isEqualToString:@"Space-Key"] || [name isEqualToString:@"Dismiss-Key"];
}