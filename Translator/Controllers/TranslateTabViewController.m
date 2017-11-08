#import "TranslateTabViewController.h"
#import "UIColor+Compare.h"

@interface TranslateTabViewController ()

@property (strong, nonatomic) NSString *placeholderText;
@property (strong, nonatomic) UIColor  *placeholderColor;

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
}

@end
