#import "CommonViewController.h"

@interface AboutProgramViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeModalButton;

- (IBAction)closeModalButton:(UIButton *)sender;

@end
