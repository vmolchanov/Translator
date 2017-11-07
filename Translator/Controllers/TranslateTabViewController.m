#import "TranslateTabViewController.h"
#import "UIColor+Compare.h"

@interface TranslateTabViewController ()

@property (strong, nonatomic) NSString *placeholderText;
@property (strong, nonatomic) UIColor  *placeholderColor;

@end

@implementation TranslateTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputView.layer.cornerRadius = 3;
    
    // placeholder for inputTextView
    CGFloat alpha = 1.0;
    CGFloat red, green, blue;
    red = green = blue = 153.0 / 255;
    self.placeholderColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    self.placeholderText = @"Введите текст...";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Actions


- (IBAction)clearTextViewAction:(id)sender {
    [self textView:self.inputTextView setText:self.placeholderText color:self.placeholderColor];
    [sender setHidden:YES];
}


#pragma mark - UITextViewDelegate


- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.textColor isEqualToColor:self.placeholderColor]) {
        if ([textView.text length] > [self.placeholderText length]) {
            unichar inputedCharacter =  [textView.text characterAtIndex:[textView.text length] - 1];
            
            [self textView:textView
                   setText:[NSString stringWithFormat:@"%c", inputedCharacter]
                     color:[UIColor blackColor]];
            
            [self.clearTextViewButton setHidden:NO];
        } else {
            [self textView:textView setText:self.placeholderText color:self.placeholderColor];
        }
    }
    
    if ([textView.text length] == 0) {
        [self textView:textView setText:self.placeholderText color:self.placeholderColor];
        [self.clearTextViewButton setHidden:YES];
    }
}


#pragma mark - Private methods


- (void)textView:(UITextView *)textView setText:(NSString *)text color:(UIColor *)color {
    textView.text = text;
    textView.textColor = color;
}

@end
