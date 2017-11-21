#import <UIKit/UIKit.h>

@interface CommonViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *context;

- (void)view:(UIView *)view withWidth:(CGFloat)width height:(CGFloat)height x:(CGFloat)x y:(CGFloat)y;

@end
