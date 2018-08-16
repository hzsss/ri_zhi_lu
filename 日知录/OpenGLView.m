//=============================================================================================================================
//
// Copyright (c) 2015-2017 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import "OpenGLView.h"
#import "AppDelegate.h"

#import "helloar.h"

#import <easyar/engine.oc.h>

@interface OpenGLView ()
{
}

@end

@implementation OpenGLView {
    BOOL initialized;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    self->initialized = false;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self->initialized = false;
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    [self bindDrawable];
    
    return self;
}

- (void)btnClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissCtr)]) {
        [self.delegate dismissCtr];
    }
}

- (void)dealloc
{
}

- (void)start
{
    if (initialize()) {
        if (self.isVideo) { // 如果是只识别视频
            initVideo(1);
        } else { // 如果是只识别音频
            initVideo(0);
        }
        start(); // 开始识别
    }
}

- (void)stop
{
    stop();
    finalize(); // 退出并清除数据
}

- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    float scale;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
        scale = [[UIScreen mainScreen] nativeScale];
#pragma clang diagnostic pop
    } else {
        scale = [[UIScreen mainScreen] scale];
    }

    resizeGL(frame.size.width * scale, frame.size.height * scale);
}

- (void)drawRect:(CGRect)rect
{
    if (!initialized) {
        initGL();
        initialized = YES;
    }
    render();
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            [easyar_Engine setRotation:270];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [easyar_Engine setRotation:90];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [easyar_Engine setRotation:180];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [easyar_Engine setRotation:0];
            break;
        default:
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.video == 1) { // 扫描视频（横版）
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 15 - 35, 30, 35, 35)];
        [backBtn setImage:[UIImage imageNamed:@"back1"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backBtn];
        
        UIImageView *videoImage = [[UIImageView alloc] init];
        
        CGRect frame = videoImage.frame;
        frame.size = CGSizeMake(30, 500);
        frame.origin.x = 30;
        videoImage.frame = frame;
        
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        CGPoint center = videoImage.center;
        center.y = vc.view.center.y;
        videoImage.center = center;
        
        videoImage.image = [UIImage imageNamed:@"videoImage"];
        
        [self addSubview:videoImage];
        
    } else if (self.video == 0) { // 扫描音频（竖版）
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 30, 35, 35)];
        [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backBtn];
        
        UIImageView *audioImage = [[UIImageView alloc] init];
        
        CGRect frame = audioImage.frame;
        frame.size = CGSizeMake(350, 21.875);
        frame.origin.y = self.frame.size.height - 50;
        audioImage.frame = frame;
        
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        CGPoint center = audioImage.center;
        center.x = vc.view.center.x;
        audioImage.center = center;
        
        audioImage.image = [UIImage imageNamed:@"audioImage"];
        
        [self addSubview:audioImage];
    }
}

@end
