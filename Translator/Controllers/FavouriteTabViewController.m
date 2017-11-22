#import "FavouriteTabViewController.h"
#import "FavouriteTableViewCell.h"
#import "TranslateTabViewController.h"
#import "SettingsTabTableViewController.h"
#import "../Models/CoreDataManager.h"
#import "../Models/Settings/Settings+CoreDataClass.h"
#import "../Models/Favourite/Favourite+CoreDataClass.h"

NSString* const FavouriteTabViewControllerFavouritesHasPhaseNotification = @"FavouriteTabViewControllerFavouritesHasPhaseNotification";


@interface FavouriteTabViewController ()

@property (strong, nonatomic) NSMutableArray *favourites;

@end

@implementation FavouriteTabViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkTranslationNotification:)
                                                     name:TranslationTabViewControllerCheckTranslationNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addToFavouriteNotification:)
                                                     name:TranslationTabViewControllerAddToFavouriteNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeFromFavouriteNotification:)
                                                     name:TranslationTabViewControllerRemoveFromFavouriteNotification
                                                   object:nil];
        
        self.favourites = [NSMutableArray array];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // initial theme
    Settings *settingsData = [[self.context executeFetchRequest:[Settings fetchRequest]
                                                          error:nil] objectAtIndex:0];
    
    UIColor *themeColor = [CoreDataManager colorFromBitwiseMask:settingsData.themeColor];
    UIColor *fontColor = [CoreDataManager colorFromBitwiseMask:settingsData.fontColor];
    [self applyThemeWithColor:themeColor fontColor:fontColor];
    
    // load favourites from Core Data
    NSArray *favourites = [self.context executeFetchRequest:[Favourite fetchRequest] error:nil];
    
    for (Favourite *favourite in favourites) {
        NSDictionary *favouriteItem = @{@"sourcePhrase": favourite.sourceText,
                                        @"translationPhrase": favourite.translationText,
                                        @"sourceLangAbbr": favourite.sourceLanguageAbbr,
                                        @"translationLangAbbr": favourite.translationLanguageAbbr
                                        };
        [self.favourites addObject:favouriteItem];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self setAlphaForTableView:self.tableView];
    [self.tableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeDidChangeNotification:)
                                                 name:SettingsTabTableViewControllerThemeDidChangeNotification
                                               object:nil];
}


#pragma mark - Actions


- (IBAction)clearFavouriteAction:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof (self) weakSelf = self;
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Очистить избранное"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             weakSelf.favourites = [NSMutableArray array];
                                                             [weakSelf.tableView reloadData];
                                                             [weakSelf setAlphaForTableView:weakSelf.tableView];
                                                         }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Notification


- (void)checkTranslationNotification:(NSNotification *)notification {
    NSString *phrase = [notification.userInfo objectForKey:TranslationTabViewControllerTranslationUserInfoKey];
    
    for (NSDictionary *favourite in self.favourites) {
        NSString *sourcePhrase = [favourite objectForKey:@"sourcePhrase"];
        
        if ([sourcePhrase isEqualToString:phrase]) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:FavouriteTabViewControllerFavouritesHasPhaseNotification object:nil];
            return;
        }
    }
}


- (void)addToFavouriteNotification:(NSNotification *)notification {
    NSDictionary *infoAboutTranslation = [notification.userInfo
                                          objectForKey:TranslationTabViewControllerInfoAboutTranslationUserInfoKey];
    [self.favourites addObject:infoAboutTranslation];
    
    Favourite *favouriteData = [[Favourite alloc] initWithContext:self.context];
    favouriteData.sourceText = [infoAboutTranslation objectForKey:@"sourcePhrase"];
    favouriteData.translationText = [infoAboutTranslation objectForKey:@"translationPhrase"];
    favouriteData.sourceLanguageAbbr = [infoAboutTranslation objectForKey:@"sourceLangAbbr"];
    favouriteData.translationLanguageAbbr = [infoAboutTranslation objectForKey:@"translationLangAbbr"];
    
    [self.context save:nil];
}


- (void)removeFromFavouriteNotification:(NSNotification *)notification {
    NSDictionary *infoAboutTranslation = [notification.userInfo
                                          objectForKey:TranslationTabViewControllerInfoAboutTranslationUserInfoKey];
    [self deleteFavouriteItemFromCoreData:infoAboutTranslation];
    [self.favourites removeObject:infoAboutTranslation];
    [self.context save:nil];
}


- (void)themeDidChangeNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification.userInfo objectForKey:SettingsTabTableViewControllerNewThemeUserInfoKey];
    [self applyThemeWithColor:[userInfo objectForKey:@"themeColor"]
                    fontColor:[userInfo objectForKey:@"fontColor"]];
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.favourites count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *favouriteCellIdentifier = @"favouriteCell";
    
    FavouriteTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:favouriteCellIdentifier];
    if (!cell) {
        cell = [[FavouriteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:favouriteCellIdentifier];
    }
    
    NSDictionary *cellContent = [self.favourites objectAtIndex:indexPath.row];
    cell.sourceTextLabel.text = [cellContent objectForKey:@"sourcePhrase"];
    cell.translationTextLabel.text = [cellContent objectForKey:@"translationPhrase"];
    cell.sourceLanguageAbbrLabel.text = [cellContent objectForKey:@"sourceLangAbbr"];
    cell.translationLanguageAbbrLabel.text = [cellContent objectForKey:@"translationLangAbbr"];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteFavouriteItemFromCoreData:[self.favourites objectAtIndex:indexPath.row]];
    [self.favourites removeObjectAtIndex:indexPath.row];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
    [self.context save:nil];
    
    __weak typeof (self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf setAlphaForTableView:weakSelf.tableView];
    });
}


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}


- (void)setAlphaForTableView:(UITableView *)tableView {
    tableView.alpha = [self.favourites count] ? 1.0f : 0.0f;
}


- (void)applyThemeWithColor:(UIColor *)color fontColor:(UIColor *)fontColor {
    [self.topBar setBackgroundColor:color];
    self.topBarTitleLabel.textColor = fontColor;
    [self.clearButton setTitleColor:fontColor forState:UIControlStateNormal];
}


- (void)deleteFavouriteItemFromCoreData:(NSDictionary *)item {
    NSArray *favourites = [self.context executeFetchRequest:[Favourite fetchRequest] error:nil];
    
    for (Favourite *favourite in favourites) {
        if ([favourite.sourceText isEqualToString:[item objectForKey:@"sourcePhrase"]] &&
            [favourite.translationText isEqualToString:[item objectForKey:@"translationPhrase"]] &&
            [favourite.sourceLanguageAbbr isEqualToString:[item objectForKey:@"sourceLangAbbr"]] &&
            [favourite.translationLanguageAbbr isEqualToString:[item objectForKey:@"translationLangAbbr"]]) {
            
            [self.context deleteObject:favourite];
            break;
        }
    }
}

@end
