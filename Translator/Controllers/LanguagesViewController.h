#import <UIKit/UIKit.h>


extern NSString* const LanguagesViewControllerCellDidSelectNotification;

extern NSString* const LanguagesViewControllerChosenLanguageUserInfoKey;


@interface LanguagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSArray *languages;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)closeModalAction:(UIButton *)sender;

@end
