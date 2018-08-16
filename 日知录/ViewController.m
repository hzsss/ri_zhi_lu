//
//  ViewController.m
//  日知录
//
//  Created by 灿灿 on 2018/1/4.
//  Copyright © 2018年 长春市河马漫步文化科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "ARVedioController.h"
#import "TipViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)ARVedioClick {
    ARVedioController *arCtr = [[ARVedioController alloc] init];
    arCtr.glView.video = YES;
    [self presentViewController:arCtr animated:NO completion:nil];
}

- (IBAction)ARVoiceClick {
    ARVedioController *arCtr = [[ARVedioController alloc] init];
    arCtr.glView.video = NO;
    [self presentViewController:arCtr animated:NO completion:nil];
}

- (IBAction)tipBtnClick {
    TipViewController *tipCtr = [[TipViewController alloc] init];
    
    [self presentViewController:tipCtr animated:NO completion:nil];
}

@end
