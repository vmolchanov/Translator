#import "../Models/TranslatorAPI.h"
#import "../Models/Settings/Settings+CoreDataClass.h"

#import "LanguagesViewController.h"
#import "TranslateTabViewController.h"
#import "SettingsTabTableViewController.h"

NSString* const LanguagesViewControllerCellDidSelectNotification =
                @"LanguagesViewControllerCellDidSelectNotification";

NSString* const LanguagesViewControllerChosenLanguageUserInfoKey =
                @"LanguagesViewControllerChosenLanguageUserInfoKey";

@interface LanguagesViewController ()

@property (strong, nonatomic) NSMutableArray *filteredLanguages;

@end

@implementation LanguagesViewController

#pragma mark - Lifecycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TranslatorAPIAvailableLanguagesDidLoadNotification
                                                  object:nil];
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(languagesLoadedNotification:)
                                                 name:TranslatorAPIAvailableLanguagesDidLoadNotification
                                               object:nil];
    
    TranslatorAPI *translatorAPI = [TranslatorAPI api];
    [translatorAPI availableLanguages];
    
    // initial theme (from Core Data)
    Settings *settingsData = [[self.context executeFetchRequest:[Settings fetchRequest] error:nil] objectAtIndex:0];
    
    UIColor *themeColor = [Settings colorFromBitwiseMask:settingsData.themeColor];
    UIColor *fontColor = [Settings colorFromBitwiseMask:settingsData.fontColor];
    [self applyThemeWithColor:themeColor fontColor:fontColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)closeModalAction:(UIButton *)sender {
    [self closeModal];
}

#pragma mark - UITableViewDataSourse

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredLanguages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    NSDictionary *lang = [self.filteredLanguages objectAtIndex:indexPath.row];
    NSString *langAbbr = [[lang allKeys] objectAtIndex:0];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [lang objectForKey:langAbbr]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedCellText = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    NSDictionary *selectedLang;
    
    for (NSDictionary *lang in self.filteredLanguages) {
        NSString *abbr = [[lang allKeys] objectAtIndex:0];
        NSString *langName = [lang objectForKey:abbr];
        
        if ([langName isEqualToString:selectedCellText]) {
            selectedLang = lang;
            break;
        }
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:selectedLang
                                                         forKey:LanguagesViewControllerChosenLanguageUserInfoKey];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:LanguagesViewControllerCellDidSelectNotification
                      object:nil
                    userInfo:userInfo];
    
    [self closeModal];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        self.filteredLanguages = [NSMutableArray arrayWithArray:self.languages];
        [self.tableView reloadData];
        return;
    }
    
    self.filteredLanguages = [NSMutableArray array];
    
    for (NSDictionary *lang in self.languages) {
        NSString *abbr = [[lang allKeys] objectAtIndex:0];
        NSString *langName = [[lang objectForKey:abbr] lowercaseString];
        
        if ([langName rangeOfString:[searchText lowercaseString]].location != NSNotFound) {
            [self.filteredLanguages addObject:lang];
        }
    }
    
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - Notifications

- (void)languagesLoadedNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification.userInfo objectForKey:TranslatorAPIAvailableLanguagesUserInfoKey];
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSString *langAbbr in userInfo) {
        NSDictionary *lang = @{langAbbr: [userInfo objectForKey:langAbbr]};
        [tempArray addObject:lang];
    }
    
    self.languages = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *firstLangAbbr = [[obj1 allKeys] objectAtIndex:0];
        NSString *secondLangAbbr = [[obj2 allKeys] objectAtIndex:0];
        
        return [[obj1 objectForKey:firstLangAbbr] compare:[obj2 objectForKey:secondLangAbbr]];
    }];
    
    self.filteredLanguages = [NSMutableArray arrayWithArray:self.languages];
    
    __weak LanguagesViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });
}

#pragma mark - Private methods

- (void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)applyThemeWithColor:(UIColor *)color fontColor:(UIColor *)fontColor {
    self.topBar.backgroundColor = color;
    
    [self.cancelButton setTitleColor:fontColor forState:UIControlStateNormal];
    [self.titleLabel setTextColor:fontColor];
}

@end
