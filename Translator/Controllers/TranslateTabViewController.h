#import <UIKit/UIKit.h>

@interface TranslateTabViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UIView *outputView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearTextViewButton;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property (weak, nonatomic) IBOutlet UIButton *addToFavouriteButton;
@property (weak, nonatomic) IBOutlet UIButton *addToClipboardButton;
@property (weak, nonatomic) IBOutlet UIView *languagesBar;
@property (weak, nonatomic) IBOutlet UIButton *swapLanguagesButton;

+ (CGFloat)label:(UILabel *)label heightForText:(NSString *)text;

- (IBAction)clearTextViewAction:(id)sender;

@end
