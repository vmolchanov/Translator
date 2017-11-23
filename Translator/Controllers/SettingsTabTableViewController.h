#import "CommonViewController.h"

extern NSString* const SettingsTabTableViewControllerThemeDidChangeNotification;

extern NSString* const SettingsTabTableViewControllerNewThemeUserInfoKey;

@interface SettingsTabTableViewController : UITableViewController

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *themeColorButtons;

- (IBAction)chooseThemeAction:(UIButton *)sender;

@property (strong, nonatomic) NSManagedObjectContext *context;

@end
