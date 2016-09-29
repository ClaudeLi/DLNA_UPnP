//
//  CLUPnPRenderer.h
//  Tiaooo
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLUPnPModel;
@interface CLUPnPRenderer : NSObject

@property (nonatomic, strong) CLUPnPModel *model;

- (instancetype)initWithModel:(CLUPnPModel *)model;

// 投屏 视频url
- (void)setAVTransportURL:(NSString *)urlStr;

// 播放
- (void)play;

// 暂停
- (void)pause;

// 跳转至特定进度或视频
// Unit：REL_TIME（跳转到某个进度）或 TRACK_NR（跳转到某个视频）。
// Target： 目标值，可以是 00:02:21 格式的进度或者整数的 TRACK_NR。
- (void)seekToTarget:(NSString *)target Unit:(NSString *)unit;

@end
