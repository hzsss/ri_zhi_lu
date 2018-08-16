//
//  BeginController.m
//  日知录
//
//  Created by 灿灿 on 2018/1/10.
//  Copyright © 2018年 长春市河马漫步文化科技有限公司. All rights reserved.
//

#import "BeginController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "IntroController.h"

@interface BeginController ()
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation BeginController

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showsPlaybackControls = NO;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"launchVideo.mp4" ofType:nil];
    NSURL *videoUrl = [NSURL fileURLWithPath:filePath];
    self.player = [[AVPlayer alloc] initWithURL:videoUrl];
    
    [self.player play];
    
    
    NSUserDefaults *timeDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![timeDefaults valueForKey:@"time"]) {
        [timeDefaults setValue:@"sd" forKey:@"time"];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(jumpToIntro) userInfo:nil repeats:YES];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(enterMainAction) userInfo:nil repeats:YES];
    }
    
}

- (void)jumpToIntro {
    if (CMTimeGetSeconds(self.player.currentItem.currentTime) == CMTimeGetSeconds(self.player.currentItem.duration)) {
        [self.timer invalidate];
        self.timer = nil;
        IntroController *introCtr = [[IntroController alloc] init];
        
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        while (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }
        [vc presentViewController:introCtr animated:NO completion:nil];
    }
}

- (void)enterMainAction {
    if (CMTimeGetSeconds(self.player.currentItem.currentTime) == CMTimeGetSeconds(self.player.currentItem.duration)) {
        [self.timer invalidate];
        self.timer = nil;
        
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *main = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        
        [self presentViewController:main animated:NO completion:nil];
//        delegate.window.rootViewController = main;
//        [delegate.window makeKeyWindow];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //隐藏状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}



@end
