#import "TranslateTabViewController.h"
#import "UIColor+Compare.h"
#import "LanguagesViewController.h"

@interface TranslateTabViewController ()

@property (strong, nonatomic) NSString *placeholderText;
@property (strong, nonatomic) UIColor  *placeholderColor;

@property (strong, nonatomic) UIButton *clickedButton;

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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    if (size.width > size.height) {
        [self applyHorizontalOrientationWithScreenSize:size];
    } else {
        [self applyVerticalOrientationWithScreenSize:size];
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


- (IBAction)clearTextViewAction:(id)sender {
    [self textView:self.inputTextView setText:self.placeholderText color:self.placeholderColor];
    [sender setHidden:YES];
    [self setOutputLabelWithText:@"" favouriteButtonAsHidden:YES clipboardButtonAsHidden:YES];
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
    NSDictionary *abbr = [[userInfo allKeys] objectAtIndex:0];
    
    self.clickedButton.titleLabel.text = [userInfo objectForKey:abbr];
}


#pragma mark - UITextViewDelegate


- (void)textViewDidChange:(UITextView *)textView {
    if ([self textViewHavePlaceholder:textView]) {
        if ([textView.text length] > [self.placeholderText length]) {
            [self textView:textView
                   setText:[textView.text substringFromIndex:[textView.text length] - 1]
                     color:[UIColor blackColor]];

            [self.clearTextViewButton setHidden:NO];

            // server request
            [self setOutputLabelWithText:textView.text favouriteButtonAsHidden:NO clipboardButtonAsHidden:NO];
        } else {
            [self textView:textView setText:self.placeholderText color:self.placeholderColor];
        }
    } else if ([textView.text length] != 0) {
        // server request
        [self setOutputLabelWithText:textView.text favouriteButtonAsHidden:NO clipboardButtonAsHidden:NO];
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


- (void)applyHorizontalOrientationWithScreenSize:(CGSize)size {
    const CGFloat viewOffset = 5.0f;
    const CGFloat innerOffset = 16.0f;
    const CGFloat outputLabelLeftOffset = 23.0f;
    const CGFloat outputLabelTopOffset = 23.0f;
    const CGFloat addToFavouriteButtonBottomOffset = 20.0f;
    const CGFloat tabBarHeight = 32.0f;
    
    CGFloat langBarHeight = CGRectGetHeight(self.languagesBar.frame);
    CGFloat viewHeight = size.height - langBarHeight - 2 * viewOffset - tabBarHeight;
    CGFloat viewWidth = (size.width - 3 * viewOffset) / 2;
    
    // inputView
    CGRect inputViewBounds = self.inputView.bounds;
    inputViewBounds.size.width = viewWidth;
    inputViewBounds.size.height = viewHeight;
    self.inputView.bounds = inputViewBounds;
    
    CGRect inputViewFrame = self.inputView.frame;
    inputViewFrame.origin.x = 5;
    inputViewFrame.origin.y = langBarHeight + viewOffset;
    self.inputView.frame = inputViewFrame;
    
    // outputView
    CGRect outputViewBounds = self.outputView.bounds;
    outputViewBounds.size.width = viewWidth;
    outputViewBounds.size.height = viewHeight;
    self.outputView.bounds = outputViewBounds;
    
    CGRect outputViewFrame = self.outputView.frame;
    outputViewFrame.origin.x = viewWidth + 2 * viewOffset;
    outputViewFrame.origin.y = langBarHeight + viewOffset;
    self.outputView.frame = outputViewFrame;
    
    // inputTextView
    CGFloat inputTextViewHeight = viewHeight - 2 * innerOffset;
    CGFloat inputTextViewWidth = viewWidth - 3 * innerOffset - self.clearTextViewButton.bounds.size.width;
    
    CGRect inputTextViewBounds = self.inputTextView.bounds;
    inputTextViewBounds.size.height = inputTextViewHeight;
    inputTextViewBounds.size.width = inputTextViewWidth;
    self.inputTextView.bounds = inputTextViewBounds;
    
    CGRect inputTextViewFrame = self.inputTextView.frame;
    inputTextViewFrame.origin.x = innerOffset;
    inputTextViewFrame.origin.y = innerOffset;
    self.inputTextView.frame = inputTextViewFrame;
    
    // clearTextViewButton
    CGRect clearTextViewButtonFrame = self.clearTextViewButton.frame;
    clearTextViewButtonFrame.origin.x = 2 * innerOffset + inputTextViewWidth;
    clearTextViewButtonFrame.origin.y = innerOffset;
    self.clearTextViewButton.frame = clearTextViewButtonFrame;
    
    // outputLabel
    CGRect outputLabelBounds = self.outputLabel.bounds;
    outputLabelBounds.size.width = viewWidth - self.addToFavouriteButton.bounds.size.width - 2 * innerOffset - outputLabelLeftOffset;
    self.outputLabel.bounds = outputLabelBounds;
    
    CGRect outputLabelFrame = self.outputLabel.frame;
    outputLabelFrame.origin.x = outputLabelLeftOffset;
    outputLabelFrame.origin.y = outputLabelTopOffset;
    self.outputLabel.frame = outputLabelFrame;
    
    // scrollView
    CGRect scrollViewBounds = self.scrollView.bounds;
    scrollViewBounds.size.height = viewHeight;
    scrollViewBounds.size.width = self.outputLabel.bounds.size.width + outputLabelLeftOffset;
    self.scrollView.bounds = scrollViewBounds;
    
    CGRect scrollViewFrame = self.scrollView.frame;
    scrollViewFrame.origin.x = 0;
    scrollViewFrame.origin.y = 0;
    self.scrollView.frame = scrollViewFrame;
    
    // addToFavouriteButton
    CGRect addToFavouriteButtonFrame = self.addToFavouriteButton.frame;
    addToFavouriteButtonFrame.origin.x = outputLabelLeftOffset + self.outputLabel.bounds.size.width + innerOffset;
    addToFavouriteButtonFrame.origin.y = innerOffset;
    self.addToFavouriteButton.frame = addToFavouriteButtonFrame;
    
    // addToClipboardButton
    CGFloat favouriteAndClipboardIconDelta = self.addToFavouriteButton.frame.size.width - self.addToClipboardButton.frame.size.width;
    CGRect addToClipboardButtonFrame = self.addToClipboardButton.frame;
    addToClipboardButtonFrame.origin.x = outputLabelLeftOffset + self.outputLabel.bounds.size.width + innerOffset + favouriteAndClipboardIconDelta / 2;
    addToFavouriteButtonFrame.origin.y = innerOffset + self.addToFavouriteButton.bounds.size.height + addToFavouriteButtonBottomOffset;
    self.addToClipboardButton.frame = addToClipboardButtonFrame;
    
    // languagesBar
    CGRect languagesBarFrame = self.languagesBar.frame;
    languagesBarFrame.size.width = size.width;
    self.languagesBar.frame = languagesBarFrame;
}


- (void)applyVerticalOrientationWithScreenSize:(CGSize)size {
    const CGFloat viewOffset = 5.0f;
    const CGFloat innerOffset = 16.0f;
    const CGFloat inputViewHeight = 200.0f;
    const CGFloat outputLabelLeftOffset = 23.0f;
    const CGFloat outputLabelTopOffset = 23.0f;
    const CGFloat addToFavouriteButtonBottomOffset = 20.0f;
    const CGFloat tabBarHeight = 49.0f;
    
    CGFloat viewWidth = size.width - 2 * viewOffset;
    CGFloat langBarHeight = CGRectGetHeight(self.languagesBar.frame);
    
    // inputView
    CGRect inputViewBounds = self.inputView.bounds;
    inputViewBounds.size.width = viewWidth;
    inputViewBounds.size.height = inputViewHeight;
    self.inputView.bounds = inputViewBounds;
    
    CGRect inputViewFrame = self.inputView.frame;
    inputViewFrame.origin.x = viewOffset;
    inputViewFrame.origin.y = langBarHeight + viewOffset;
    self.inputView.frame = inputViewFrame;
    
    // outputView
    CGRect outputViewBounds = self.outputView.bounds;
    outputViewBounds.size.width = viewWidth;
    outputViewBounds.size.height = size.height - langBarHeight - inputViewHeight - 3 * viewOffset - tabBarHeight;
    self.outputView.bounds = outputViewBounds;
    
    CGRect outputViewFrame = self.outputView.frame;
    outputViewFrame.origin.x = viewOffset;
    outputViewFrame.origin.y = langBarHeight + 2 * viewOffset + self.inputView.bounds.size.height;
    self.outputView.frame = outputViewFrame;
    
    // inputTextView
    CGFloat inputTextViewHeight = inputViewHeight - 2 * innerOffset;
    CGFloat inputTextViewWidth = viewWidth - 3 * innerOffset - self.clearTextViewButton.bounds.size.width;
    
    CGRect inputTextViewBounds = self.inputTextView.bounds;
    inputTextViewBounds.size.width = inputTextViewWidth;
    inputTextViewBounds.size.height = inputTextViewHeight;
    self.inputTextView.bounds = inputTextViewBounds;
    
    CGRect inputTextViewFrame = self.inputTextView.frame;
    inputTextViewFrame.origin.x = innerOffset;
    inputTextViewFrame.origin.y = innerOffset;
    self.inputTextView.frame = inputTextViewFrame;
    
    // clearTextViewButton
    CGRect clearTextViewButtonFrame = self.clearTextViewButton.frame;
    clearTextViewButtonFrame.origin.x = 2 * innerOffset + inputTextViewWidth;
    clearTextViewButtonFrame.origin.y = innerOffset;
    self.clearTextViewButton.frame = clearTextViewButtonFrame;
    
    // outputLabel
    CGRect outputLabelBounds = self.outputLabel.bounds;
    outputLabelBounds.size.width = viewWidth - self.addToFavouriteButton.bounds.size.width - 2 * innerOffset - outputLabelLeftOffset;
    self.outputLabel.bounds = outputLabelBounds;
    
    CGRect outputLabelFrame = self.outputLabel.frame;
    outputLabelFrame.origin.x = outputLabelLeftOffset;
    outputLabelFrame.origin.y = outputLabelTopOffset;
    self.outputLabel.frame = outputLabelFrame;
    
    // scrollView
    CGRect scrollViewBounds = self.scrollView.bounds;
    scrollViewBounds.size.height = self.outputView.bounds.size.height;
    scrollViewBounds.size.width = self.outputLabel.bounds.size.width + outputLabelLeftOffset;
    self.scrollView.bounds = scrollViewBounds;
    
    CGRect scrollViewFrame = self.scrollView.frame;
    scrollViewFrame.origin.x = 0;
    scrollViewFrame.origin.y = 0;
    self.scrollView.frame = scrollViewFrame;
    
    // addToFavouriteButton
    CGRect addToFavouriteButtonFrame = self.addToFavouriteButton.frame;
    addToFavouriteButtonFrame.origin.x = outputLabelLeftOffset + self.outputLabel.bounds.size.width + innerOffset;
    addToFavouriteButtonFrame.origin.y = innerOffset;
    self.addToFavouriteButton.frame = addToFavouriteButtonFrame;
    
    // addToClipboardButton
    CGFloat favouriteAndClipboardIconDelta = self.addToFavouriteButton.frame.size.width - self.addToClipboardButton.frame.size.width;
    CGRect addToClipboardButtonFrame = self.addToClipboardButton.frame;
    addToClipboardButtonFrame.origin.x = outputLabelLeftOffset + self.outputLabel.bounds.size.width + innerOffset + favouriteAndClipboardIconDelta / 2;
    addToFavouriteButtonFrame.origin.y = innerOffset + self.addToFavouriteButton.bounds.size.height + addToFavouriteButtonBottomOffset;
    self.addToClipboardButton.frame = addToClipboardButtonFrame;
    
    // languagesBar
    CGRect languagesBarFrame = self.languagesBar.frame;
    languagesBarFrame.size.width = size.width;
    self.languagesBar.frame = languagesBarFrame;
}

@end
