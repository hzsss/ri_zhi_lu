//
//  ARVedioController.m
//  日知录
//
//  Created by 灿灿 on 2018/1/5.
//  Copyright © 2018年 长春市河马漫步文化科技有限公司. All rights reserved.
//

#import "ARVedioController.h"

#import "OpenGLView.h"

@interface ARVedioController()<OpenGLViewDelegate>

@end

@implementation ARVedioController {
//    OpenGLView *glView;
}

- (OpenGLView *)glView {
    if (!_glView) {
        _glView = [[OpenGLView alloc] initWithFrame:CGRectZero];
        _glView.delegate = self;
    }
    return _glView;
}

- (void)dismissCtr {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)loadView {
//    self->_glView = [[OpenGLView alloc] initWithFrame:CGRectZero];
    
    self.view = self->_glView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self->_glView setOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self->_glView start];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self->_glView stop];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self->_glView resize:self.view.bounds orientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self->_glView setOrientation:toInterfaceOrientation];
}

@end
