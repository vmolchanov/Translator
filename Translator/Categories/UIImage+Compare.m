#import "UIImage+Compare.h"

@implementation UIImage (Compare)

- (BOOL)isEqualToImage:(UIImage *)image {
    NSData *firstImageData = UIImagePNGRepresentation(self);
    NSData *secondImageData = UIImagePNGRepresentation(image);
    
    return [firstImageData isEqualToData:secondImageData];
}

@end
