//
//  TipViewController.m
//  日知录
//
//  Created by Jarvis on 2018/2/27.
//  Copyright © 2018年 长春市河马漫步文化科技有限公司. All rights reserved.
//

#import "TipViewController.h"

@interface TipViewController ()
@property (weak, nonatomic) IBOutlet UIButton *jump2downloadBtn;

@end

@implementation TipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.jump2downloadBtn.titleLabel.font = [UIFont fontWithName:@"FZQingKeBenYueSongS-R-GB" size:15.f];
//    self.jump2downloadBtn.titleLabel.numberOfLines = 2;
//    self.jump2downloadBtn.titleLabel.text = @"点击下载\n《长春日知录》电子书";
    
    [self.jump2downloadBtn addTarget:self action:@selector(jump2download) forControlEvents:UIControlEventTouchUpInside];
    
}
- (IBAction)backBtnClick {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)jump2download {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rzl.jljujin.com/eBook/changchunrizhilu_eBook.pdf"]];
}

@end
