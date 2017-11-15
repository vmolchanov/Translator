#import "FavouriteTabViewController.h"
#import "FavouriteTableViewCell.h"
#import "TranslateTabViewController.h"

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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.tableView reloadData];
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
}


- (void)removeFromFavouriteNotification:(NSNotification *)notification {
    NSDictionary *infoAboutTranslation = [notification.userInfo
                                          objectForKey:TranslationTabViewControllerInfoAboutTranslationUserInfoKey];
    [self.favourites removeObject:infoAboutTranslation];
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
    [self.favourites removeObjectAtIndex:indexPath.row];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}

@end
