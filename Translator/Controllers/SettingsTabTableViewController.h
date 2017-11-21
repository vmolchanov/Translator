#import "CommonViewController.h"

extern NSString* const SettingsTabTableViewControllerThemeDidChangeNotification;

extern NSString* const SettingsTabTableViewControllerNewThemeUserInfoKey;


@interface SettingsTabTableViewController : UITableViewController

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *themeColorButtons;
@property (strong, nonatomic) NSManagedObjectContext *context;

- (IBAction)chooseThemeAction:(UIButton *)sender;

@end
