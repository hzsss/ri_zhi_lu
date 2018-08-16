//
//  ARVedioController.h
//  日知录
//
//  Created by 灿灿 on 2018/1/5.
//  Copyright © 2018年 长春市河马漫步文化科技有限公司. All rights reserved.
//

#import <GLKit/GLKViewController.h>
#import "OpenGLView.h"
@interface ARVedioController : GLKViewController
//@property (nonatomic, assign, getter=isVideo) BOOL video;
@property (nonatomic, strong) OpenGLView *glView;
@end
