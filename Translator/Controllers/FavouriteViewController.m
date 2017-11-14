#import "FavouriteViewController.h"
#import "FavouriteTableViewCell.h"

@interface FavouriteViewController ()

@property (strong, nonatomic) NSArray *favourites;

@end

@implementation FavouriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    return cell;
}

@end
