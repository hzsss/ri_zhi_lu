//=============================================================================================================================
//
// Copyright (c) 2015-2017 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import "helloar.h"

#import "BoxRenderer.h"
#import "ARVideo.h"
#import "VideoRenderer.h"

#import <easyar/types.oc.h>
#import <easyar/camera.oc.h>
#import <easyar/frame.oc.h>
#import <easyar/framestreamer.oc.h>
#import <easyar/imagetracker.oc.h>
#import <easyar/imagetarget.oc.h>
#import <easyar/renderer.oc.h>
#import <easyar/cloud.oc.h>

#include <OpenGLES/ES2/gl.h>
#import "AFNetworking.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayerController.h"
#import "AudioController.h"
#import "AppDelegate.h"

extern NSString * cloud_server_address;
extern NSString * cloud_key;
extern NSString * cloud_secret;

easyar_CameraDevice * camera;
easyar_CameraFrameStreamer * streamer;
NSMutableArray<easyar_ImageTracker *> * trackers;
easyar_Renderer * videobg_renderer;
BoxRenderer * box_renderer;
easyar_CloudRecognizer * cloud_recognizer;
bool viewport_changed = false;
int view_size[] = {0, 0};
int view_rotation = 0;
int viewport[] = {0, 0, 1280, 720};
NSMutableSet<NSString *> * uids;

NSMutableArray<VideoRenderer *> * video_renderers = nil;
int tracked_target = 0;
int active_target = 0;
int isVideoOrAudio = 0; // 判断是音频还是视频
ARVideo * video = nil;
VideoRenderer * current_video_renderer = nil;

NSString *picName; // 识别图名字
NSDictionary *dict; // 字典

void initVideo(int isVideo) {
    isVideoOrAudio = isVideo;
}

BOOL initialize()
{
    camera = [easyar_CameraDevice create];
    streamer = [easyar_CameraFrameStreamer create];
    [streamer attachCamera:camera];
    cloud_recognizer = [easyar_CloudRecognizer create];
    [cloud_recognizer attachStreamer:streamer];

    bool status = true;
    status &= [camera open:easyar_CameraDeviceType_Default];
    [camera setSize:[easyar_Vec2I create:@[@1280, @720]]];
    uids = [[NSMutableSet<NSString *> alloc] init];
    
    // 根据cloud返回判断值
    [cloud_recognizer open:cloud_server_address appKey:cloud_key appSecret:cloud_secret callback_open:^(easyar_CloudStatus status) {
        if (status == easyar_CloudStatus_Success ) {
            NSLog(@"CloudRecognizerInitCallBack: Success");
        } else if (status == easyar_CloudStatus_Reconnecting) {
            NSLog(@"CloudRecognizerInitCallBack: Reconnecting");
        } else if (status == easyar_CloudStatus_Fail) {
            NSLog(@"CloudRecognizerInitCallBack: Fail");
        } else {
            NSLog(@"CloudRecognizerInitCallBack: %ld", (long)status);
        }
    } callback_recognize:^(easyar_CloudStatus status, NSArray<easyar_Target *> * targets) {
        if (status == easyar_CloudStatus_Success ) {
//            picName = targets.lastObject.name;
            
            NSLog(@"CloudRecognizerCallBack: Success");
        } else if (status == easyar_CloudStatus_Reconnecting) {
            NSLog(@"CloudRecognizerCallBack: Reconnecting");
        } else if (status == easyar_CloudStatus_Fail) {
            NSLog(@"CloudRecognizerCallBack: Fail");
        } else {
            NSLog(@"CloudRecognizerCallBack: %ld", (long)status);
        }
        @synchronized (uids) {
            for (easyar_Target * t in targets) {
                if (![uids containsObject:[t uid]]) {
                    NSLog(@"add cloud target: uid---------%@", [t uid]);
                    [uids addObject:[t uid]];
                    [[trackers objectAtIndex:0] loadTarget:t callback:^(easyar_Target *target, bool status) {
                        NSLog(@"load target (%@): %@ (%d)", status ? @"true" : @"false", [target name], [target runtimeID]);
                    }];
                }
            }
        }
    }];

    if (!status) { return status; }
    easyar_ImageTracker * tracker = [easyar_ImageTracker create];
    [tracker attachStreamer:streamer];
    trackers = [[NSMutableArray<easyar_ImageTracker *> alloc] init];
    [trackers addObject:tracker];

    return status;
}

void finalize()
{
    [trackers removeAllObjects];
    cloud_recognizer = nil;
    box_renderer = nil;
    videobg_renderer = nil;
    streamer = nil;
    camera = nil;
}

BOOL start() // 开始识别
{
    bool status = true;
    status &= (camera != nil) && [camera start];
    status &= (streamer != nil) && [streamer start];
    status &= (cloud_recognizer != nil) && [cloud_recognizer start];
    [camera setFocusMode:easyar_CameraDeviceFocusMode_Continousauto];
    for (easyar_ImageTracker * tracker in trackers) {
        status &= [tracker start];
    }
    return status;
}

BOOL stop()
{
    bool status = true;
    for (easyar_ImageTracker * tracker in trackers) {
        status &= [tracker stop];
    }
    status &= (cloud_recognizer != nil) && [cloud_recognizer stop];
    status &= (streamer != nil) && [streamer stop];
    status &= (camera != nil) && [camera stop];
    return status;
}

void initGL()
{
//    videobg_renderer = [easyar_Renderer create];
//    box_renderer = [BoxRenderer alloc];
//    [box_renderer init_];
    if (active_target != 0) {
        [video onLost];
        video = nil;
        tracked_target = 0;
        active_target = 0;
    }
    videobg_renderer = nil;
    videobg_renderer = [easyar_Renderer create];
    video_renderers = [[NSMutableArray<VideoRenderer *> alloc] init];
    for (int k = 0; k < 3; k += 1) {
        VideoRenderer * video_renderer = [[VideoRenderer alloc] init];
        [video_renderer init_];
        [video_renderers addObject:video_renderer];
    }
    current_video_renderer = nil;
}

void resizeGL(int width, int height)
{
    view_size[0] = width;
    view_size[1] = height;
    viewport_changed = true;
}

void updateViewport()
{
    easyar_CameraCalibration * calib = camera != nil ? [camera cameraCalibration] : nil;
    int rotation = calib != nil ? [calib rotation] : 0;
    if (rotation != view_rotation) {
        view_rotation = rotation;
        viewport_changed = true;
    }
    if (viewport_changed) {
        int size[] = {1, 1};
        if (camera && [camera isOpened]) {
            size[0] = [[[camera size].data objectAtIndex:0] intValue];
            size[1] = [[[camera size].data objectAtIndex:1] intValue];
        }
        if (rotation == 90 || rotation == 270) {
            int t = size[0];
            size[0] = size[1];
            size[1] = t;
        }
        float scaleRatio = MAX((float)view_size[0] / (float)size[0], (float)view_size[1] / (float)size[1]);
        int viewport_size[] = {(int)roundf(size[0] * scaleRatio), (int)roundf(size[1] * scaleRatio)};
        int viewport_new[] = {(view_size[0] - viewport_size[0]) / 2, (view_size[1] - viewport_size[1]) / 2, viewport_size[0], viewport_size[1]};
        memcpy(&viewport[0], &viewport_new[0], 4 * sizeof(int));
        
        if (camera && [camera isOpened])
            viewport_changed = false;
    }
}

void render()
{
    glClearColor(1.f, 1.f, 1.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if (videobg_renderer != nil) {
        int default_viewport[] = {0, 0, view_size[0], view_size[1]};
        easyar_Vec4I * oc_default_viewport = [easyar_Vec4I create:@[[NSNumber numberWithInt:default_viewport[0]], [NSNumber numberWithInt:default_viewport[1]], [NSNumber numberWithInt:default_viewport[2]], [NSNumber numberWithInt:default_viewport[3]]]];
        glViewport(default_viewport[0], default_viewport[1], default_viewport[2], default_viewport[3]);
        if ([videobg_renderer renderErrorMessage:oc_default_viewport]) {
            return;
        }
    }

    if (streamer == nil) { return; }
    easyar_Frame * frame = [streamer peek];
    updateViewport();
    glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);

    if (videobg_renderer != nil) {
        [videobg_renderer render:frame viewport:[easyar_Vec4I create:@[[NSNumber numberWithInt:viewport[0]], [NSNumber numberWithInt:viewport[1]], [NSNumber numberWithInt:viewport[2]], [NSNumber numberWithInt:viewport[3]]]]];
    }
    
    NSArray<easyar_TargetInstance *> * targetInstances = [frame targetInstances];
    if ([targetInstances count] > 0) {
        easyar_TargetInstance * targetInstance = [targetInstances objectAtIndex:0];
        easyar_Target * target = [targetInstance target]; // 目标图片
        int status = [targetInstance status];
        if (status == easyar_TargetStatus_Tracked) {
            int runtimeID = [target runtimeID];
            if (active_target != 0 && active_target != runtimeID) {
                [video onLost];
                video = nil;
                tracked_target = 0;
                active_target = 0;
            }
            if (tracked_target == 0) {
                video = [[ARVideo alloc] init];
//                [video openStreamingVideo:path texid:[[video_renderers objectAtIndex:2] texid]];
                
                if ([[target name] hasPrefix:@"auhttp"]) { // 播放音频
                    if (isVideoOrAudio == 1) return;
                    
                    picName = [[target name] substringWithRange:NSMakeRange(2, [target name].length-2)];
                    
                    // 先获取url，再modal控制器，异步加载数据
                    
                    // 文字
                    NSString *titleStr = [picName stringByAppendingString:@"title.txt"];
                    
                    // 图片
                    NSString *picStr = [picName stringByAppendingString:@"image.jpg"];
                    
                    // mp3
                    NSString *musicStr = [picName stringByAppendingString:@"audio.mp3"];
                    
                    AudioController *audioCtr = [[AudioController alloc] init];
                    audioCtr.titleStr = titleStr;
                    audioCtr.picStr = picStr;
                    audioCtr.musicStr = musicStr;
                    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
                    
                    while (vc.presentedViewController) {
                        vc = vc.presentedViewController;
                    }
                    
                    [vc presentViewController:audioCtr animated:NO completion:nil];
                } else { // 播放视频
                    if (isVideoOrAudio == 0) return;
                    
                    PlayerController *playCtr = [[PlayerController alloc] init];
                    playCtr.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:[target name]]];
                    playCtr.videoGravity = AVLayerVideoGravityResizeAspect;
                    if (@available(iOS 11.0, *)) {
                        playCtr.entersFullScreenWhenPlaybackBegins = YES;
                    } else {
                        // Fallback on earlier versions
                    }
                    [playCtr.player play];
                    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
                    
                    while (vc.presentedViewController) {
                        vc = vc.presentedViewController;
                    }
                    [vc presentViewController:playCtr animated:NO completion:nil];
                }
                
                current_video_renderer = [video_renderers objectAtIndex:2];
                if (video != nil) {
                    [video onFound];
                    tracked_target = runtimeID;
                    active_target = runtimeID;
                }
            }
            easyar_ImageTarget * imagetarget = [target isKindOfClass:[easyar_ImageTarget class]] ? (easyar_ImageTarget *)target : nil;
            if (imagetarget != nil) {
                if (current_video_renderer != nil) {
                    [video update];
                    if ([video isRenderTextureAvailable]) {
                        [current_video_renderer render:[camera projectionGL:0.2f farPlane:500.f] cameraview:[targetInstance poseGL] size:[imagetarget size]];
                    }
                }
            }
        }
    } else {
        if (tracked_target != 0) {
            [video onLost];
            tracked_target = 0;
        }
    }
}

