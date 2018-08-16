//=============================================================================================================================
//
// Copyright (c) 2015-2017 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import <GLKit/GLKView.h>

@protocol OpenGLViewDelegate <NSObject>
- (void)dismissCtr;
@end
@interface OpenGLView : GLKView
@property (nonatomic, assign, getter=isVideo) BOOL video;
@property (nonatomic, weak) id<OpenGLViewDelegate> delegate;
- (void)start;
- (void)stop;
- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation;
- (void)setOrientation:(UIInterfaceOrientation)orientation;

@end
