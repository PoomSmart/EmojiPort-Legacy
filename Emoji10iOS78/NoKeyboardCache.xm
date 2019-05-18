%hook UIKeyboardCache

+ (BOOL)enabled {
    return NO;
}

%end

// iOS 6 Keyboard UI
%hook UIKBRenderFactory

+ (BOOL)_enabled {
    return NO;
}

%end