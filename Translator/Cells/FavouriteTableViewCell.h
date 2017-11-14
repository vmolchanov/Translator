#import <UIKit/UIKit.h>

@interface FavouriteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sourceTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *translationTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceLanguageAbbrLabel;
@property (weak, nonatomic) IBOutlet UILabel *translationLanguageAbbrLabel;

@end
