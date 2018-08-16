//
//  AudioController.m
//  日知录
//
//  Created by 灿灿 on 2018/1/9.
//  Copyright © 2018年 长春市河马漫步文化科技有限公司. All rights reserved.
//



#import "AudioController.h"
#import <AVFoundation/AVFoundation.h>
@interface AudioController () {
    BOOL flag;
}
@property (weak, nonatomic) IBOutlet UIImageView *picView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playAndPauseBtn;
@property (nonatomic, strong) AVPlayer *musicPlayer;
@property (nonatomic, strong) AVPlayerItem *songItem;
@property (nonatomic, strong) id timeObserve;
@property (weak, nonatomic) IBOutlet UISlider *mySlider;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
- (IBAction)dismissBtnClick;

@end

@implementation AudioController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak __typeof(self) weakSelf = self;
    
    // 加载文字
    NSURL *titleUrl = [NSURL URLWithString:self.titleStr];
    self.titleLabel.text = [NSString stringWithContentsOfURL:titleUrl encoding:NSUTF8StringEncoding error:nil];
    self.titleLabel.font = [UIFont fontWithName:@"FZQingKeBenYueSongS-R-GB" size:15.f];
    self.titleLabel.numberOfLines = 0;
    
    // 加载图片
    NSURL *picUrl = [NSURL URLWithString:self.picStr];
    self.picView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:picUrl]];
    
    NSURL *musicUrl = [NSURL URLWithString:self.musicStr];
    
    AVPlayerItem *songItem = [AVPlayerItem playerItemWithURL:musicUrl];
    self.songItem = songItem;
    self.musicPlayer = [[AVPlayer alloc] initWithPlayerItem:self.songItem];
    
    [self.musicPlayer play];
    
    id timeObserve = [self.musicPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 100.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(songItem.duration);
        
        if (current) {
            weakSelf.mySlider.value = (current / total);
            int currentInt = (int)current;
            weakSelf.currentTimeLabel.text = [NSString stringWithFormat:@"00:%02d",  currentInt];
            weakSelf.totalTimeLabel.text = [NSString stringWithFormat:@"00:%.0f", total];
        }
    }];
    
    self.timeObserve = timeObserve;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:songItem];
    
    [self.mySlider setThumbImage:[UIImage imageNamed:@"timeO"] forState:UIControlStateNormal];
    [self.mySlider setThumbImage:[UIImage imageNamed:@"timeO"] forState:UIControlStateHighlighted];
//    [self.mySlider setThumbTintColor:[UIColor whiteColor]];
    
    
    [self.playAndPauseBtn addTarget:self action:@selector(playAndPauseBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)playFinished {
    if (_timeObserve) {
        [self.musicPlayer removeTimeObserver:_timeObserve];
        _timeObserve = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playAndPauseBtnClick {
    if (!flag) {
        flag = !flag;
        [self.musicPlayer pause];
        [self.playAndPauseBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        [self.playAndPauseBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateHighlighted];
    } else {
        flag = !flag;
        [self.musicPlayer play];
        [self.playAndPauseBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self.playAndPauseBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateHighlighted];
    }
}


- (IBAction)dismissBtnClick {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.picView.frame;
    frame.origin.y = 160;
    frame.size.width = self.view.frame.size.width;
    frame.size.height = (self.picView.image.size.height / self.picView.image.size.width) * self.view.frame.size.width;
    self.picView.frame = frame;
    
    CGPoint picCenter = self.picView.center;
    picCenter.x = self.view.center.x;
    self.picView.center = picCenter;
//    self.picView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.origin.y = self.picView.frame.origin.y + self.picView.frame.size.height + 20;
    titleFrame.size.width = self.view.frame.size.width;
    
    CGPoint titlePoint = self.titleLabel.center;
    titlePoint.x = self.view.center.x;
    
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.titleLabel.font, NSFontAttributeName, nil]];
    titleFrame.size.height = titleSize.height;
    
    self.titleLabel.frame = titleFrame;
    
    NSLog(@"%@", NSStringFromCGRect(self.titleLabel.frame));
}
@end
