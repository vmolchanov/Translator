#import "TranslateTabViewController.h"
#import "UIColor+Compare.h"
#import "UIImage+Compare.h"
#import "LanguagesViewController.h"
#import "TranslatorAPI.h"
#import "FavouriteTabViewController.h"

NSString* const TranslationTabViewControllerCheckTranslationNotification = @"TranslationTabViewControllerCheckTranslationNotification";
NSString* const TranslationTabViewControllerAddToFavouriteNotification = @"TranslationTabViewControllerAddToFavouriteNotification";
NSString* const TranslationTabViewControllerRemoveFromFavouriteNotification = @"TranslationTabViewControllerRemoveFromFavouriteNotification";

NSString* const TranslationTabViewControllerTranslationUserInfoKey = @"TranslationTabViewControllerTranslationUserInfoKey";
NSString* const TranslationTabViewControllerInfoAboutTranslationUserInfoKey = @"TranslationTabViewControllerInfoAboutTranslationUserInfoKey";


@interface TranslateTabViewController ()

@property (strong, nonatomic) NSString *placeholderText;
@property (strong, nonatomic) UIColor  *placeholderColor;
@property (strong, nonatomic) UIButton *clickedButton;
@property (strong, nonatomic) NSString *detectedLanguage;

@end

@implementation TranslateTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set corner radius
    self.inputView.layer.cornerRadius = 3;
    self.outputView.layer.cornerRadius = 3;
    
    // placeholder for inputTextView
    CGFloat alpha = 1.0;
    CGFloat red, green, blue;
    red = green = blue = 153.0 / 255;
    self.placeholderColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    self.placeholderText = @"Введите текст...";
    
    // output label
    [self setOutputLabelWithText:@"" favouriteButtonAsHidden:YES clipboardButtonAsHidden:YES];
    
    // hide keyboard
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditingAction)];
    [self.inputView addGestureRecognizer:gr];
    [self.outputView addGestureRecognizer:gr];
    
    // initial language
    self.sourceLanguageAbbr = @"en";
    self.translationLanguageAbbr = @"ru";
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self viewWillTransitionToSize:[[UIScreen mainScreen] bounds].size withTransitionCoordinator:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setTranslationNotification:)
                                                 name:TranslatorAPITranslationDidCompleteNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(detectedOtherSourceLanguageNotification:)
                                                 name:TranslatorAPIDetectedOtherSourceLanguageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favouritesHasPhraseNotification:)
                                                 name:FavouriteTabViewControllerFavouritesHasPhaseNotification
                                               object:nil];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    static const CGFloat viewOffset = 5.0f;
    static const CGFloat innerOffset = 16.0f;
    static const CGFloat inputViewHeight = 200.0f;
    static const CGFloat outputLabelLeftOffset = 23.0f;
    static const CGFloat outputLabelTopOffset = 23.0f;
    static const CGFloat addToFavouriteButtonBottomOffset = 20.0f;
    
    CGFloat langBarHeight = CGRectGetHeight(self.languagesBar.frame);
    CGFloat favouriteAndClipboardIconDelta = self.addToFavouriteButton.bounds.size.width - self.addToClipboardButton.bounds.size.width;
    
    if (size.width > size.height) {
        const CGFloat tabBarHeight = 32.0f;
        
        CGFloat viewHeight = size.height - langBarHeight - 2 * viewOffset - tabBarHeight;
        CGFloat viewWidth = (size.width - 3 * viewOffset) / 2;
        
        CGFloat inputTextViewHeight = viewHeight - 2 * innerOffset;
        CGFloat inputTextViewWidth = viewWidth - 3 * innerOffset - self.clearTextViewButton.bounds.size.width;
        
        [self view:self.inputView
         withWidth:viewWidth
            height:viewHeight
                 x:5
                 y:langBarHeight + viewOffset];
        
        [self view:self.outputView
         withWidth:viewWidth
            height:viewHeight
                 x:viewWidth + 2 * viewOffset
                 y:langBarHeight + viewOffset];
        
        [self view:self.inputTextView
         withWidth:inputTextViewWidth
            height:inputTextViewHeight
                 x:innerOffset
                 y:innerOffset];
        
        [self view:self.clearTextViewButton
         withWidth:self.clearTextViewButton.bounds.size.width
            height:self.clearTextViewButton.bounds.size.height
                 x:2 * innerOffset + inputTextViewWidth
                 y:innerOffset];
        
        [self view:self.outputLabel
         withWidth:viewWidth - self.addToFavouriteButton.bounds.size.width - 2 * innerOffset - outputLabelLeftOffset
            height:self.outputLabel.bounds.size.height
                 x:outputLabelLeftOffset
                 y:outputLabelLeftOffset];
        
        [self view:self.scrollView
         withWidth:self.outputLabel.bounds.size.width + outputLabelLeftOffset
            height:viewHeight
                 x:0
                 y:0];
        
        [self view:self.addToFavouriteButton
         withWidth:self.addToFavouriteButton.bounds.size.width
            height:self.addToFavouriteButton.bounds.size.height
                 x:outputLabelLeftOffset + self.outputLabel.bounds.size.width + innerOffset
                 y:innerOffset];
        
        [self view:self.addToClipboardButton
         withWidth:self.addToClipboardButton.bounds.size.width
            height:self.addToClipboardButton.bounds.size.height
                 x:outputLabelLeftOffset + self.outputLabel.bounds.size.width + innerOffset + favouriteAndClipboardIconDelta / 2
                 y:innerOffset + self.addToFavouriteButton.bounds.size.height + addToFavouriteButtonBottomOffset];
        
        [self view:self.languagesBar
         withWidth:size.width
            height:self.languagesBar.bounds.size.height
                 x:self.languagesBar.frame.origin.x
                 y:self.languagesBar.frame.origin.y];
        
    } else {
        const CGFloat tabBarHeight = 49.0f;
        
        CGFloat viewWidth = size.width - 2 * viewOffset;
        
        CGFloat inputTextViewHeight = inputViewHeight - 2 * innerOffset;
        CGFloat inputTextViewWidth = viewWidth - 3 * innerOffset - self.clearTextViewButton.bounds.size.width;
        
        [self view:self.inputView
         withWidth:viewWidth
            height:inputViewHeight
                 x:viewOffset
                 y:langBarHeight + viewOffset];
        
        [self view:self.outputView
         withWidth:viewWidth
            height:size.height - langBarHeight - inputViewHeight - 3 * viewOffset - tabBarHeight
                 x:viewOffset
                 y:langBarHeight + 2 * viewOffset + self.inputView.bounds.size.height];
        
        [self view:self.inputTextView
         withWidth:inputTextViewWidth
            height:inputTextViewHeight
                 x:innerOffset
                 y:innerOffset];
        
        [self view:self.clearTextViewButton
         withWidth:self.clearTextViewButton.bounds.size.width
            height:self.clearTextViewButton.bounds.size.height
                 x:2 * innerOffset + inputTextViewWidth
                 y:innerOffset];
        
        [self view:self.outputLabel
         withWidth:viewWidth - self.addToFavouriteButton.bounds.size.width - 2 * innerOffset - outputLabelLeftOffset
            height:self.outputLabel.bounds.size.height
                 x:outputLabelLeftOffset
                 y:outputLabelTopOffset];
        
        [self view:self.scrollView
         withWidth:self.outputLabel.bounds.size.width + outputLabelLeftOffset
            height:self.outputView.bounds.size.height
                 x:0
                 y:0];
        
        [self view:self.addToFavouriteButton
         withWidth:self.addToFavouriteButton.bounds.size.width
            height:self.addToFavouriteButton.bounds.size.height
                 x:outputLabelLeftOffset + self.outputLabel.bounds.size.width + innerOffset
                 y:innerOffset];
        
        [self view:self.addToClipboardButton
         withWidth:self.addToClipboardButton.bounds.size.width
            height:self.addToClipboardButton.bounds.size.height
                 x:outputLabelLeftOffset + self.outputLabel.bounds.size.width + innerOffset + favouriteAndClipboardIconDelta / 2
                 y:innerOffset + self.addToFavouriteButton.bounds.size.height + addToFavouriteButtonBottomOffset];
        
        [self view:self.languagesBar
         withWidth:size.width
            height:self.languagesBar.bounds.size.height
                 x:self.languagesBar.frame.origin.x
                 y:self.languagesBar.frame.origin.y];
    }
}


#pragma mark - Static methods


+ (CGFloat)label:(UILabel *)label heightForText:(NSString *)text {
    
    UIFont *font = [UIFont systemFontOfSize:17.0f];
    
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    return CGRectGetHeight(rect);
}


#pragma mark - Actions


- (IBAction)clearTextViewAction:(UIButton *)sender {
    [self textView:self.inputTextView setText:self.placeholderText color:self.placeholderColor];
    [sender setHidden:YES];
    [self setOutputLabelWithText:@"" favouriteButtonAsHidden:YES clipboardButtonAsHidden:YES];
}


- (IBAction)swapLanguagesAction:(UIButton *)sender {
    [self swapLanguages];
}


- (IBAction)addToClipboardAction:(UIButton *)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.outputLabel.text;
}


- (IBAction)addToFavouriteAction:(UIButton *)sender {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    NSDictionary *infoAboutTranslation = @{@"sourcePhrase": self.inputTextView.text,
                                           @"translationPhrase": self.outputLabel.text,
                                           @"sourceLangAbbr": self.sourceLanguageAbbr,
                                           @"translationLangAbbr": self.translationLanguageAbbr
                                           };
    NSDictionary *userInfo = [NSDictionary
                              dictionaryWithObject:infoAboutTranslation
                                            forKey:TranslationTabViewControllerInfoAboutTranslationUserInfoKey];
    
    if ([[sender currentImage] isEqualToImage:[UIImage imageNamed:@"starIcon"]]) {
        [self.addToFavouriteButton setImage:[UIImage imageNamed:@"starIconSelected"] forState:UIControlStateNormal];
        [nc postNotificationName:TranslationTabViewControllerAddToFavouriteNotification
                          object:nil
                        userInfo:userInfo];
    } else {
        [self.addToFavouriteButton setImage:[UIImage imageNamed:@"starIcon"] forState:UIControlStateNormal];
        [nc postNotificationName:TranslationTabViewControllerRemoveFromFavouriteNotification
                          object:nil
                        userInfo:userInfo];
    }
}


- (void)endEditingAction {
    [self.inputView endEditing:YES];
    [self.outputView endEditing:YES];
}


#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.clickedButton = sender;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setNewLanguageNotification:)
                                                 name:LanguagesViewControllerCellDidSelectNotification
                                               object:nil];
}


#pragma mark - Notification


- (void)setNewLanguageNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification.userInfo objectForKey:LanguagesViewControllerChosenLanguageUserInfoKey];
    NSString *abbr = [[userInfo allKeys] objectAtIndex:0];
    
    UIButton *unclickedButton;
    
    if ([self.clickedButton isEqual:self.sourceLanguageButton]) {
        unclickedButton = self.translationLanguageButton;
    } else {
        unclickedButton = self.sourceLanguageButton;
    }
    
    if ([[userInfo objectForKey:abbr] isEqualToString:unclickedButton.titleLabel.text]) {
        [self swapLanguages];
    } else {
        [self.clickedButton setTitle:[userInfo objectForKey:abbr] forState:UIControlStateNormal];
        if ([self.clickedButton isEqual:self.sourceLanguageButton]) {
            self.sourceLanguageAbbr = abbr;
        } else {
            self.translationLanguageAbbr = abbr;
        }
    }
}


- (void)setTranslationNotification:(NSNotification *)notification {
    NSString *translation = [[notification.userInfo objectForKey:TranslatorAPITranslationTextUserInfoKey] objectAtIndex:0];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf setOutputLabelWithText:translation favouriteButtonAsHidden:NO clipboardButtonAsHidden:NO];
        [weakSelf.addToFavouriteButton setImage:[UIImage imageNamed:@"starIcon"]
                                       forState:UIControlStateNormal];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:weakSelf.inputTextView.text
                                                             forKey:TranslationTabViewControllerTranslationUserInfoKey];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:TranslationTabViewControllerCheckTranslationNotification
                          object:nil
                        userInfo:userInfo];
    });
}


- (void)detectedOtherSourceLanguageNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setDetectedSourceLanguageNotification:)
                                                 name:TranslatorAPIAvailableLanguagesDidLoadNotification
                                               object:nil];
    
    self.detectedLanguage = [notification.userInfo valueForKey:TranslatorAPIOtherSourceLanguageUserInfoKey];
    
    TranslatorAPI *translateAPI = [TranslatorAPI api];
    [translateAPI availableLanguages];
}


- (void)setDetectedSourceLanguageNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TranslatorAPIAvailableLanguagesDidLoadNotification
                                                  object:nil];
    
    NSDictionary *languages = [notification.userInfo valueForKey:TranslatorAPIAvailableLanguagesUserInfoKey];
    
    for (NSString *abbr in languages) {
        if ([abbr isEqualToString:self.detectedLanguage]) {
            __weak typeof (self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *translationLanguageButtonText = weakSelf.translationLanguageButton.titleLabel.text;
                
                if ([[languages objectForKey:abbr] isEqualToString:translationLanguageButtonText]) {
                    [weakSelf swapLanguages];
                } else {
                    weakSelf.sourceLanguageAbbr = abbr;
                }
                
                [weakSelf.sourceLanguageButton setTitle:[languages objectForKey:abbr]
                                               forState:UIControlStateNormal];
            });
            break;
        }
    }
}


- (void)favouritesHasPhraseNotification:(NSNotification *)notification {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.addToFavouriteButton setImage:[UIImage imageNamed:@"starIconSelected"]
                                       forState:UIControlStateNormal];
    });
}


#pragma mark - UITextViewDelegate


- (void)textViewDidChange:(UITextView *)textView {
    TranslatorAPI *translatorAPI = [TranslatorAPI api];
    
    if ([self textViewHavePlaceholder:textView]) {
        if ([textView.text length] > [self.placeholderText length]) {
            [self textView:textView
                   setText:[textView.text substringFromIndex:[textView.text length] - 1]
                     color:[UIColor blackColor]];

            [self.clearTextViewButton setHidden:NO];

            [translatorAPI translateText:textView.text from:self.sourceLanguageAbbr to:self.translationLanguageAbbr];
        } else {
            [self textView:textView setText:self.placeholderText color:self.placeholderColor];
        }
    } else if ([textView.text length] != 0) {
        [translatorAPI translateText:textView.text from:self.sourceLanguageAbbr to:self.translationLanguageAbbr];
    }

    if ([textView.text length] == 0) {
        [self textView:textView setText:self.placeholderText color:self.placeholderColor];
        [self.clearTextViewButton setHidden:YES];
        [self setOutputLabelWithText:@"" favouriteButtonAsHidden:YES clipboardButtonAsHidden:YES];
    }
}


#pragma mark - Private methods


- (void)textView:(UITextView *)textView setText:(NSString *)text color:(UIColor *)color {
    textView.text = text;
    textView.textColor = color;
}


- (BOOL)textViewHavePlaceholder:(UITextView *)textView {
    return [self.inputTextView.textColor isEqualToColor:self.placeholderColor];
}


- (void)setOutputLabelWithText:(NSString *)text
       favouriteButtonAsHidden:(BOOL)fbhide
       clipboardButtonAsHidden:(BOOL)cbhide {
    
    CGFloat labelHeight = [TranslateTabViewController label:self.outputLabel heightForText:text];
    
    CGRect labelFrame = self.outputLabel.frame;
    labelFrame.size.height = labelHeight;
    
    self.outputLabel.frame = labelFrame;
    self.outputLabel.text = text;
    
    [self.addToFavouriteButton setHidden:fbhide];
    [self.addToClipboardButton setHidden:cbhide];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, labelHeight);
}


- (void)swapLanguages {
    NSString *temp = self.sourceLanguageButton.titleLabel.text;
    [self.sourceLanguageButton setTitle:self.translationLanguageButton.titleLabel.text forState:UIControlStateNormal];
    [self.translationLanguageButton setTitle:temp forState:UIControlStateNormal];
    
    NSString *tempAbbr = self.sourceLanguageAbbr;
    self.sourceLanguageAbbr = self.translationLanguageAbbr;
    self.translationLanguageAbbr = tempAbbr;
}

@end
