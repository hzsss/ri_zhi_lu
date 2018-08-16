//
//  IntroController.m
//  日知录
//
//  Created by Jarvis on 2018/1/23.
//  Copyright © 2018年 长春市河马漫步文化科技有限公司. All rights reserved.
//

#import "IntroController.h"
#import "AppDelegate.h"
#define ImageCount 5
@interface IntroController ()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *enterBtn;
@property (nonatomic, weak) UIPageControl *pageControl;
@end

@implementation IntroController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    CGRect pageControlframe = pageControl.frame;
    pageControlframe.size = CGSizeMake(200, 30);
    pageControlframe.origin.y = self.view.frame.size.height - 30;
    pageControl.frame = pageControlframe;
    
    CGPoint pageControlCenter = pageControl.center;
    pageControlCenter.x = self.view.center.x;
    pageControl.center = pageControlCenter;
    pageControl.numberOfPages = ImageCount;
    [self.view addSubview:pageControl];
    
    self.pageControl = pageControl;
}

- (void)setupScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    scrollView.delegate = self;
    self.scrollView = scrollView;
    [self.view addSubview:self.scrollView];
    
    CGFloat imageX;
    CGFloat imageY = 0;
    CGSize imageSize = self.view.frame.size;
    CGFloat imageW = imageSize.width;
    CGFloat imageH = imageSize.height;
    
    for (int i=1; i<=ImageCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageX = (i-1) * self.view.frame.size.width;
        imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
        
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"intro%d", i]];
        
        if (i == ImageCount) {
            UIButton *enterBtn = [[UIButton alloc] init];
            CGRect frame = enterBtn.frame;
            frame.size = CGSizeMake(170, 47);
            frame.origin.y = self.view.frame.size.height - 150;
            enterBtn.frame = frame;
            
            CGPoint center = enterBtn.center;
            center.x = self.view.center.x + (ImageCount - 1) * self.view.frame.size.width;
            enterBtn.center = center;
            
            [enterBtn setImage:[UIImage imageNamed:@"enterBtn"] forState:UIControlStateNormal];
            
            self.enterBtn = enterBtn;
        }
        
        [self.scrollView addSubview:imageView];
        [self.scrollView addSubview:self.enterBtn];
    }
    [self.enterBtn addTarget:self action:@selector(enterMainAction) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat contentW = ImageCount *imageW;
    CGFloat contentH = self.view.frame.size.height;
    
    self.scrollView.contentSize = CGSizeMake(contentW, contentH);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffSet = scrollView.contentOffset;
    self.pageControl.currentPage = contentOffSet.x / self.view.frame.size.width;
}

- (void)enterMainAction {
    UIViewController *main = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    
    [self presentViewController:main animated:NO completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
