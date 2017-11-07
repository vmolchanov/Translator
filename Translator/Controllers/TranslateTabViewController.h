#import <UIKit/UIKit.h>

@interface TranslateTabViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearTextViewButton;

- (IBAction)clearTextViewAction:(id)sender;

@end
