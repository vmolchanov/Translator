#import "../Models/Settings/Settings+CoreDataClass.h"

#import "AboutProgramViewController.h"

@interface AboutProgramViewController ()

@end

@implementation AboutProgramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Settings *settingsData = [[self.context executeFetchRequest:[Settings fetchRequest] error:nil] objectAtIndex:0];
    UIColor *themeColor = [Settings colorFromBitwiseMask:settingsData.themeColor];
    UIColor *fontColor = [Settings colorFromBitwiseMask:settingsData.fontColor];
    [self applyThemeWithColor:themeColor fontColor:fontColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)closeModalButton:(UIButton *)sender {
    [self closeModal];
}

#pragma mark - Private methods

- (void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)applyThemeWithColor:(UIColor *)color fontColor:(UIColor *)fontColor {
    self.view.backgroundColor = color;
    self.topBar.backgroundColor = color;
    self.titleLabel.textColor = fontColor;
    [self.closeModalButton setTitleColor:fontColor forState:UIControlStateNormal];
}

@end
