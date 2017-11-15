#import "CommonViewController.h"

extern NSString* const FavouriteTabViewControllerFavouritesHasPhaseNotification;


@interface FavouriteTabViewController : CommonViewController <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
