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
    [self setAlphaForTableView:self.tableView];
    [self.tableView reloadData];
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

@end
