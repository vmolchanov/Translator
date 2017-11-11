#import "CommonViewController.h"

@interface CommonViewController ()

@end

@implementation CommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)view:(UIView *)view withWidth:(CGFloat)width height:(CGFloat)height x:(CGFloat)x y:(CGFloat)y {
    CGRect inputViewBounds = view.bounds;
    inputViewBounds.size.width = width;
    inputViewBounds.size.height = height;
    view.bounds = inputViewBounds;
    
    CGRect inputViewFrame = view.frame;
    inputViewFrame.origin.x = x;
    inputViewFrame.origin.y = y;
    view.frame = inputViewFrame;
}

@end
