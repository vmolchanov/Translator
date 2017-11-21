#import "SettingsTabTableViewController.h"
#import "../Models/CoreDataManager.h"
#import "../Models/Settings/Settings+CoreDataClass.h"

NSString* const SettingsTabTableViewControllerThemeDidChangeNotification = @"SettingsTabTableViewControllerThemeDidChangeNotification";

NSString* const SettingsTabTableViewControllerNewThemeUserInfoKey = @"SettingsTabTableViewControllerNewThemeUserInfoKey";


enum {
    BlackTheme = 0,
    YellowTheme,
    PurpleTheme,
    RedTheme,
    GreenTheme,
    PinkTheme
} Theme;

@interface SettingsTabTableViewController ()

@property (strong, nonatomic) UIColor *themeColor;
@property (strong, nonatomic) UIColor *fontColor;

@end

@implementation SettingsTabTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.allowsSelection = NO;
//    [[self.themeColorButtons objectAtIndex:2] setSelected:YES];
    
    // initial theme
    Settings *settingsData = [[self.context executeFetchRequest:[Settings fetchRequest]
                                                          error:nil] objectAtIndex:0];
    
    UIColor *themeColor = [CoreDataManager colorFromBitwiseMask:settingsData.themeColor];
    UIColor *fontColor = [CoreDataManager colorFromBitwiseMask:settingsData.fontColor];
    [self applyThemeWithColor:themeColor fontColor:fontColor];
    
    for (UIButton *button in self.themeColorButtons) {
        if ([button tag] == settingsData.themeId) {
            [button setSelected:YES];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Core Data


- (NSManagedObjectContext *)context {
    if (self->_context == nil) {
        self->_context = [[CoreDataManager defaultManager] managedObjectContext];
    }
    
    return self->_context;
}


#pragma mark - Actions


- (IBAction)chooseThemeAction:(UIButton *)sender {
    for (UIButton *button in self.themeColorButtons) {
        if ([button isSelected]) {
            [button setSelected:NO];
        }
    }
    
    [sender setSelected:YES];
    
    Settings *settingsData = [[self.context executeFetchRequest:[Settings fetchRequest]
                                                          error:nil] objectAtIndex:0];
    
    switch ([sender tag]) {
        case BlackTheme:
            [self themeColorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
            [self fontColorWithRed:255.0f green:255.0f blue:255.0f alpha:1.0f];
            settingsData.themeColor = [CoreDataManager bitwiseMaskByRedColor:0 greenColor:0 blueColor:0];
            settingsData.fontColor = [CoreDataManager bitwiseMaskByRedColor:255 greenColor:255 blueColor:255];
            settingsData.themeId = BlackTheme;
            break;
        case YellowTheme:
            [self themeColorWithRed:248.0f green:231.0f blue:28.0f alpha:1.0f];
            [self fontColorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
            settingsData.themeColor = [CoreDataManager bitwiseMaskByRedColor:248 greenColor:231 blueColor:28];
            settingsData.fontColor = [CoreDataManager bitwiseMaskByRedColor:0 greenColor:0 blueColor:0];
            settingsData.themeId = YellowTheme;
            break;
        case PurpleTheme:
            [self themeColorWithRed:157.0f green:35.0f blue:245.0f alpha:1.0f];
            [self fontColorWithRed:255.0f green:255.0f blue:255.0f alpha:1.0f];
            settingsData.themeColor = [CoreDataManager bitwiseMaskByRedColor:157 greenColor:35 blueColor:245];
            settingsData.fontColor = [CoreDataManager bitwiseMaskByRedColor:255 greenColor:255 blueColor:255];
            settingsData.themeId = PurpleTheme;
            break;
        case RedTheme:
            [self themeColorWithRed:253.0f green:76.0f blue:42.0f alpha:1.0f];
            [self fontColorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
            settingsData.themeColor = [CoreDataManager bitwiseMaskByRedColor:253 greenColor:76 blueColor:42];
            settingsData.fontColor = [CoreDataManager bitwiseMaskByRedColor:0 greenColor:0 blueColor:0];
            settingsData.themeId = RedTheme;
            break;
        case GreenTheme:
            [self themeColorWithRed:76.0f green:210.0f blue:49.0f alpha:1.0f];
            [self fontColorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
            settingsData.themeColor = [CoreDataManager bitwiseMaskByRedColor:76 greenColor:210 blueColor:49];
            settingsData.fontColor = [CoreDataManager bitwiseMaskByRedColor:0 greenColor:0 blueColor:0];
            settingsData.themeId = GreenTheme;
            break;
        case PinkTheme:
            [self themeColorWithRed:247.0f green:105.0f blue:198.0f alpha:1.0f];
            [self fontColorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
            settingsData.themeColor = [CoreDataManager bitwiseMaskByRedColor:247 greenColor:105 blueColor:198];
            settingsData.fontColor = [CoreDataManager bitwiseMaskByRedColor:0 greenColor:0 blueColor:0];
            settingsData.themeId = PinkTheme;
            break;
            
        default:
            break;
    }
    
    [self.context save:nil];
    
    [self applyThemeWithColor:self.themeColor fontColor:self.fontColor];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@{@"themeColor": self.themeColor,
                                                                  @"fontColor": self.fontColor
                                                                  }
                                                         forKey:SettingsTabTableViewControllerNewThemeUserInfoKey];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SettingsTabTableViewControllerThemeDidChangeNotification
                      object:nil
                    userInfo:userInfo];
}


#pragma mark - Private methods


- (void)themeColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    self.themeColor = [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:alpha];
}


- (void)fontColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    self.fontColor = [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:alpha];
}


- (void)applyThemeWithColor:(UIColor *)color fontColor:(UIColor *)fontColor {
    self.navigationController.navigationBar.barTintColor = color;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: fontColor};
}

@end
