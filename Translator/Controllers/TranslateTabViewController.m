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
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    UIButton *unclickedButton;
    
    if ([self.clickedButton isEqual:self.sourceLanguageButton]) {
        unclickedButton = self.translationLanguageButton;
    } else {
        unclickedButton = self.sourceLanguageButton;
    }
    
    if ([[userInfo objectForKey:abbr] isEqualToString:unclickedButton.titleLabel.text]) {
        NSString *temp = self.clickedButton.titleLabel.text;
        [self.clickedButton setTitle:unclickedButton.titleLabel.text forState:UIControlStateNormal];
        [unclickedButton setTitle:temp forState:UIControlStateNormal];
    } else {
        [self.clickedButton setTitle:[userInfo objectForKey:abbr] forState:UIControlStateNormal];
    }
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


- (void)view:(UIView *)view withWidth:(CGFloat)width height:(CGFloat)height x:(CGFloat)x y:(CGFloat)y {
    CGRect inputViewBounds = view.bounds;
    inputViewBounds.size.width = width;
    inputViewBounds.size.height = height;
    view.bounds = inputViewBounds;
    
    CGRect inputViewFrame = view.frame;
    inputViewFrame.origin.x = x;
    inputViewFrame.origin.y = y;
    view.frame = inputViewFrame;
}

@end
