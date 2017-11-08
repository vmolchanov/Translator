#import <UIKit/UIKit.h>

@interface LanguagesViewController : UIViewController

@property (strong, nonatomic) NSArray *languages;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)closeModalAction:(UIButton *)sender;

@end
