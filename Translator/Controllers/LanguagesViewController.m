#import "LanguagesViewController.h"
#import "../Models/TranslatorAPI.h"

@interface LanguagesViewController ()

@end

@implementation LanguagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(languagesLoadedNotification:)
                                                 name:TranslatorAPIAvailableLanguagesDidLoadNotification
                                               object:nil];
    
    TranslatorAPI *translatorAPI = [TranslatorAPI api];
    [translatorAPI availableLanguages];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions


- (IBAction)closeModalAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDataSourse


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.languages count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    NSDictionary *lang = [self.languages objectAtIndex:indexPath.row];
    NSString *langAbbr = [[lang allKeys] objectAtIndex:0];
    
        
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [lang objectForKey:langAbbr]];
    
    
    return cell;
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
    
    __weak LanguagesViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
    });
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
