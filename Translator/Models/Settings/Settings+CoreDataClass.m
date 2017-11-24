#import "Settings+CoreDataClass.h"

@implementation Settings

#pragma mark - Static methods

+ (UIColor *)colorFromBitwiseMask:(int32_t)bitwiseMask {
    int32_t mask = 255;
    
    int32_t red = bitwiseMask >> 16;
    int32_t green = (bitwiseMask >> 8) & mask;
    int32_t blue = bitwiseMask & mask;
    
    return [UIColor colorWithRed:(CGFloat)red / 255
                           green:(CGFloat)green / 255
                            blue:(CGFloat)blue / 255
                           alpha:1.0f];
}

+ (int32_t)bitwiseMaskByRedColor:(int32_t)red greenColor:(int32_t)green blueColor:(int32_t)blue {
    return (red << 16) | (green << 8) | blue;
}

@end
