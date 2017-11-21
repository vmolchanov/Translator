#import <UIKit/UIKit.h>
#import "CommonViewController.h"


extern NSString* const LanguagesViewControllerCellDidSelectNotification;

extern NSString* const LanguagesViewControllerChosenLanguageUserInfoKey;


@interface LanguagesViewController : CommonViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSArray *languages;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)closeModalAction:(UIButton *)sender;

@end
