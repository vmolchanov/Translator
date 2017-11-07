#import "UIColor+Compare.h"

@implementation UIColor (Compare)

- (BOOL)isEqualToColor:(UIColor *)color {
    NSString *firstColorAsString = [[CIColor colorWithCGColor:self.CGColor] stringRepresentation];
    NSString *secondColorAsString = [[CIColor colorWithCGColor:color.CGColor] stringRepresentation];
    
    return [firstColorAsString isEqualToString:secondColorAsString];
}

@end
