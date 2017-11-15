#import <UIKit/UIKit.h>
#import "CommonViewController.h"

extern NSString* const TranslationTabViewControllerCheckTranslationNotification;
extern NSString* const TranslationTabViewControllerAddToFavouriteNotification;
extern NSString* const TranslationTabViewControllerRemoveFromFavouriteNotification;

extern NSString* const TranslationTabViewControllerTranslationUserInfoKey;
extern NSString* const TranslationTabViewControllerInfoAboutTranslationUserInfoKey;


@interface TranslateTabViewController : CommonViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView       *inputView;
@property (weak, nonatomic) IBOutlet UIView       *outputView;
@property (weak, nonatomic) IBOutlet UIView       *languagesBar;
@property (weak, nonatomic) IBOutlet UITextView   *inputTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel      *outputLabel;
@property (weak, nonatomic) IBOutlet UIButton     *clearTextViewButton;
@property (weak, nonatomic) IBOutlet UIButton     *addToFavouriteButton;
@property (weak, nonatomic) IBOutlet UIButton     *addToClipboardButton;
@property (weak, nonatomic) IBOutlet UIButton     *swapLanguagesButton;
@property (weak, nonatomic) IBOutlet UIButton     *sourceLanguageButton;
@property (weak, nonatomic) IBOutlet UIButton     *translationLanguageButton;

- (IBAction)clearTextViewAction:(UIButton *)sender;
- (IBAction)swapLanguagesAction:(UIButton *)sender;
- (IBAction)addToClipboardAction:(UIButton *)sender;
- (IBAction)addToFavouriteAction:(UIButton *)sender;


@property (strong, nonatomic) NSString *sourceLanguageAbbr;
@property (strong, nonatomic) NSString *translationLanguageAbbr;

+ (CGFloat)label:(UILabel *)label heightForText:(NSString *)text;

@end
