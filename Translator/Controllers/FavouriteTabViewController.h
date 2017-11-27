#import "CommonViewController.h"

@interface FavouriteTabViewController : CommonViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *topBarTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

- (IBAction)clearFavouriteAction:(UIButton *)sender;

@end
