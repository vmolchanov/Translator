#import "CommonViewController.h"

extern NSString* const FavouriteTabViewControllerFavouritesHasPhaseNotification;


@interface FavouriteTabViewController : CommonViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end