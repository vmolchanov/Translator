#import "UIColor+Compare.h"
#import "UIImage+Compare.h"

#import "../Models/TranslatorAPI.h"
#import "../Models/Translation/Translation+CoreDataClass.h"
#import "../Models/Settings/Settings+CoreDataClass.h"
#import "../Models/Favourite/Favourite+CoreDataClass.h"

#import "TranslateTabViewController.h"
#import "LanguagesViewController.h"
#import "SettingsTabTableViewController.h"

NSString* const TranslationTabViewControllerAddToFavouriteNotification =
                @"TranslationTabViewControllerAddToFavouriteNotification";
NSString* const TranslationTabViewControllerRemoveFromFavouriteNotification =
                @"TranslationTabViewControllerRemoveFromFavouriteNotification";

NSString* const TranslationTabViewControllerTranslationUserInfoKey =
                @"TranslationTabViewControllerTranslationUserInfoKey";
NSString* const TranslationTabViewControllerInfoAboutTranslationUserInfoKey =
                @"TranslationTabViewControllerInfoAboutTranslationUserInfoKey";

@interface TranslateTabViewController ()

@property (strong, nonatomic) NSString *placeholderText;
@property (strong, nonatomic) UIColor  *placeholderColor;
@property (strong, nonatomic) UIButton *clickedButton;
@property (strong, nonatomic) NSString *detectedLanguage;

@end

@implementation TranslateTabViewController

#pragma mark - Lifecycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View controller lifecycle

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
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(endEditingAction)];
    [self.inputView addGestureRecognizer:gr];
    [self.outputView addGestureRecognizer:gr];
    
    // initial language
    NSError *translationDataError = nil;
    NSArray *translationDataArray = [self.context executeFetchRequest:[Translation fetchRequest]
                                                                error:&translationDataError];
    if (translationDataError) {
        [translationDataError localizedDescription];
    }
    
    if ([translationDataArray count] != 0) {
        Translation *translationData = [translationDataArray objectAtIndex:0];
        
        [self.sourceLanguageButton setTitle:translationData.sourceLanguageName
                                   forState:UIControlStateNormal];
        [self.translationLanguageButton setTitle:translationData.translationLanguageName
                                        forState:UIControlStateNormal];
        self.sourceLanguageAbbr = translationData.sourceLanguageAbbr;
        self.translationLanguageAbbr = translationData.translationLanguageAbbr;
    } else {
        [self.sourceLanguageButton setTitle:@"Английский" forState:UIControlStateNormal];
        [self.translationLanguageButton setTitle:@"Русский" forState:UIControlStateNormal];
        self.sourceLanguageAbbr = @"en";
        self.translationLanguageAbbr = @"ru";
        
        Translation *translationData = [[Translation alloc] initWithContext:self.context];
        translationData.sourceLanguageName = @"Английский";
        translationData.translationLanguageName = @"Русский";
        translationData.sourceLanguageAbbr = @"en";
        translationData.translationLanguageAbbr = @"ru";
    }
    
    // initial theme
    NSError *settingsDataError = nil;
    NSArray *settingsDataArray = [self.context executeFetchRequest:[Settings fetchRequest] error:&settingsDataError];
    if (settingsDataError) {
        [settingsDataError localizedDescription];
    }
    
    Settings *settingsData =    [settingsDataArray count] != 0 ?
                                [settingsDataArray objectAtIndex:0] :
                                [[Settings alloc] initWithContext:self.context];
    
    int32_t mask = 255;
    
    int32_t themeRedColor   = [settingsDataArray count] != 0 ? settingsData.themeColor >> 16         : 157;
    int32_t themeGreenColor = [settingsDataArray count] != 0 ? (settingsData.themeColor >> 8) & mask : 35;
    int32_t themeBlueColor  = [settingsDataArray count] != 0 ? settingsData.themeColor & mask        : 245;
    
    int32_t fontRedColor   = [settingsDataArray count] != 0 ? settingsData.fontColor >> 16         : 255;
    int32_t fontGreenColor = [settingsDataArray count] != 0 ? (settingsData.fontColor >> 8) & mask : 255;
    int32_t fontBlueColor  = [settingsDataArray count] != 0 ? settingsData.fontColor & mask        : 255;
    
    UIColor *themeColor = [UIColor colorWithRed:(CGFloat)themeRedColor / 255
                                          green:(CGFloat)themeGreenColor / 255
                                           blue:(CGFloat)themeBlueColor / 255
                                          alpha:1.0f];
    UIColor *fontColor = [UIColor colorWithRed:(CGFloat)fontRedColor / 255
                                         green:(CGFloat)fontGreenColor / 255
                                          blue:(CGFloat)fontBlueColor / 255
                                         alpha:1.0f];
    [self applyThemeWithColor:themeColor fontColor:fontColor];
    
    if ([settingsDataArray count] == 0) {
        int32_t themeRGBColorBitwiseMask = [Settings bitwiseMaskByRedColor:themeRedColor
                                                                greenColor:themeGreenColor
                                                                 blueColor:themeBlueColor];
        int32_t fontRGBColorBitwiseMask = [Settings bitwiseMaskByRedColor:fontRedColor
                                                               greenColor:fontGreenColor
                                                                blueColor:fontBlueColor];
        
        Settings *settingsData = [[Settings alloc] initWithContext:self.context];
        settingsData.themeId = 2;
        settingsData.themeColor = themeRGBColorBitwiseMask;
        settingsData.fontColor = fontRGBColorBitwiseMask;
        settingsData.isRotate = YES;
        settingsData.isTranslationByEnter = NO;
    }
    
    [self.context save:nil];
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
    
    if ([self.inputTextView.text length] != 0) {
        [self setStarIcon];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeDidChangeNotification:)
                                                 name:SettingsTabTableViewControllerThemeDidChangeNotification
                                               object:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    static const CGFloat viewOffset = 5.0f;
    static const CGFloat innerOffset = 16.0f;
    static const CGFloat inputViewHeight = 200.0f;
    static const CGFloat outputLabelLeftOffset = 23.0f;
    static const CGFloat tabBarHeight = 49.0f;
    
    CGFloat langBarHeight = CGRectGetHeight(self.languagesBar.frame);
    CGFloat outputLabelWidth = CGRectGetWidth(self.outputLabel.bounds);
    
    CGRect tabBarBounds = self.tabBarController.tabBar.bounds;
    tabBarBounds.size.height = 49.0f;
    self.tabBarController.tabBar.bounds = tabBarBounds;
    
    if (size.width > size.height) {
        CGFloat viewHeight = size.height - langBarHeight - 2 * viewOffset - tabBarHeight;
        CGFloat viewWidth = (size.width - 3 * viewOffset) / 2;
        
        CGFloat inputTextViewHeight = viewHeight - 2 * innerOffset;
        CGFloat inputTextViewWidth = viewWidth - 3 * innerOffset - CGRectGetWidth(self.clearTextViewButton.bounds);
        
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
         withWidth:CGRectGetWidth(self.clearTextViewButton.bounds)
            height:CGRectGetHeight(self.clearTextViewButton.bounds)
                 x:2 * innerOffset + inputTextViewWidth
                 y:innerOffset];
        
        [self view:self.scrollView
         withWidth:outputLabelWidth + outputLabelLeftOffset
            height:viewHeight
                 x:0
                 y:0];
        
        [self view:self.languagesBar
         withWidth:size.width
            height:CGRectGetHeight(self.languagesBar.bounds)
                 x:CGRectGetMinX(self.languagesBar.frame)
                 y:CGRectGetMinY(self.languagesBar.frame)];
    } else {
        CGFloat viewWidth = size.width - 2 * viewOffset;
        
        CGFloat inputTextViewHeight = inputViewHeight - 2 * innerOffset;
        CGFloat inputTextViewWidth = viewWidth - 3 * innerOffset - CGRectGetWidth(self.clearTextViewButton.bounds);
        
        [self view:self.inputView
         withWidth:viewWidth
            height:inputViewHeight
                 x:viewOffset
                 y:langBarHeight + viewOffset];
        
        [self view:self.outputView
         withWidth:viewWidth
            height:size.height - langBarHeight - inputViewHeight - 3 * viewOffset - tabBarHeight
                 x:viewOffset
                 y:langBarHeight + 2 * viewOffset + CGRectGetHeight(self.inputView.bounds)];
        
        [self view:self.inputTextView
         withWidth:inputTextViewWidth
            height:inputTextViewHeight
                 x:innerOffset
                 y:innerOffset];
        
        [self view:self.clearTextViewButton
         withWidth:CGRectGetWidth(self.clearTextViewButton.bounds)
            height:CGRectGetHeight(self.clearTextViewButton.bounds)
                 x:2 * innerOffset + inputTextViewWidth
                 y:innerOffset];
        
        [self view:self.scrollView
         withWidth:outputLabelWidth + outputLabelLeftOffset
            height:CGRectGetHeight(self.outputView.bounds)
                 x:0
                 y:0];
        
        [self view:self.languagesBar
         withWidth:size.width
            height:CGRectGetHeight(self.languagesBar.bounds)
                 x:CGRectGetMinX(self.languagesBar.frame)
                 y:CGRectGetMinY(self.languagesBar.frame)];
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
    
    Translation *translationData = [[self.context executeFetchRequest:[Translation fetchRequest]
                                                                error:nil] objectAtIndex:0];
    
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
            
            translationData.sourceLanguageAbbr = abbr;
            translationData.sourceLanguageName = [userInfo objectForKey:abbr];
        } else {
            self.translationLanguageAbbr = abbr;
            
            translationData.translationLanguageAbbr = abbr;
            translationData.translationLanguageName = [userInfo objectForKey:abbr];
        }
    }
    
    [self.context save:nil];
}

- (void)setTranslationNotification:(NSNotification *)notification {
    NSArray *userInfo = [notification.userInfo objectForKey:TranslatorAPITranslationTextUserInfoKey];
    NSString *translation = [userInfo objectAtIndex:0];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf setOutputLabelWithText:translation favouriteButtonAsHidden:NO clipboardButtonAsHidden:NO];
        [self setStarIcon];
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
    
    Translation *translationData = [[self.context executeFetchRequest:[Translation fetchRequest]
                                                                error:nil] objectAtIndex:0];
    
    for (NSString *abbr in languages) {
        if ([abbr isEqualToString:self.detectedLanguage]) {
            __weak typeof (self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *translationLanguageButtonText = weakSelf.translationLanguageButton.titleLabel.text;
                
                if ([[languages objectForKey:abbr] isEqualToString:translationLanguageButtonText]) {
                    [weakSelf swapLanguages];
                } else {
                    weakSelf.sourceLanguageAbbr = abbr;
                    [weakSelf.sourceLanguageButton setTitle:[languages objectForKey:abbr]
                                                   forState:UIControlStateNormal];
                    
                    translationData.sourceLanguageAbbr = abbr;
                    translationData.sourceLanguageName = [languages objectForKey:abbr];
                    
                    [self.context save:nil];
                }
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

- (void)themeDidChangeNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification.userInfo objectForKey:SettingsTabTableViewControllerNewThemeUserInfoKey];
    [self applyThemeWithColor:[userInfo objectForKey:@"themeColor"]
                    fontColor:[userInfo objectForKey:@"fontColor"]];
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
    
    // Core Data
    Translation *translationData = [[self.context executeFetchRequest:[Translation fetchRequest]
                                                                error:nil] objectAtIndex:0];
    translationData.sourceLanguageName = self.translationLanguageButton.titleLabel.text;
    translationData.translationLanguageName = self.sourceLanguageButton.titleLabel.text;
    translationData.sourceLanguageAbbr = self.sourceLanguageAbbr;
    translationData.translationLanguageAbbr = self.translationLanguageAbbr;
    
    [self.context save:nil];
}

- (void)setStarIcon {
    [self.addToFavouriteButton setImage:[UIImage imageNamed:@"starIcon"] forState:UIControlStateNormal];
    
    NSArray *favouriteData = [self.context executeFetchRequest:[Favourite fetchRequest] error:nil];
    
    for (Favourite *favouriteItem in favouriteData) {
        if ([self.inputTextView.text isEqualToString:favouriteItem.sourceText]) {
            [self.addToFavouriteButton setImage:[UIImage imageNamed:@"starIconSelected"] forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)applyThemeWithColor:(UIColor *)color fontColor:(UIColor *)fontColor {
    self.languagesBar.backgroundColor = color;
    self.view.backgroundColor = color;
    
    [self.sourceLanguageButton setTitleColor:fontColor forState:UIControlStateNormal];
    [self.translationLanguageButton setTitleColor:fontColor forState:UIControlStateNormal];
}

@end
