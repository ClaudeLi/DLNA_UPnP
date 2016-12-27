//
//  CLControlViewController.m
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/10/8.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLControlViewController.h"

static NSString *urlStr0 = @"http://v.tiaooo.com/ltQ3C0vts84B-UZ9BZNvTo9lUzWU";
static NSString *urlStr1 = @"http://v.tiaooo.com/llbizosAzGhJPXC0H4AHLTGHl42W";
static NSString *urlStr2 = @"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8";
//static NSString *urlStr3 = @"http://222.73.132.145/vkphls.tc.qq.com/mp4/8/yZ_j6ME6N3hgRF2xg_m13zCxeLHcQzm9bVK0v_J-08OdcAVc0rmGCA/q4WgUBCu27O21hhzjGXkPCaHr1EkTFuUGbXKrNbjMACA-wleQI3oi3woUdjgP-BtBxW34UkmIxlQ_TkPGeqTLwghaijDM7oFlQwmCbieZPLUh33Q7f8eag/i0021mzabfm.p209.mp4/i0021mzabfm.p209.mp4.av.m3u8";

@interface CLControlViewController ()<CLUPnPResponseDelegate>{
    BOOL _isPlaying;
    CLUPnPRenderer *render;
    NSInteger _valume;
}

@end

@implementation CLControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _valume = 0;
    
    render = [[CLUPnPRenderer alloc] initWithModel:self.model];
    render.delegate = self;
    [render setAVTransportURL:@"http://218.200.160.29/rdp2/v5.5/sub/listen.do?contentid=60054703976&ua=Iphone_Sst&version=4.239&netType=1&toneFlag=1"];
    [render setNextAVTransportURI:urlStr1];
    _isPlaying = YES;
}

#pragma mark -
#pragma mark - 动作调用 -
- (IBAction)closeAction:(id)sender {
    [render stop];
}

- (IBAction)playOrPause:(id)sender {
    if (_isPlaying) {
        [render pause];
    }else{
        [render play];
    }
    _isPlaying = !_isPlaying;
}

- (IBAction)seekTo01:(id)sender {
    [render seekToTarget:@"00:00:01" Unit:unitREL_TIME];
}

- (IBAction)seekTo11:(id)sender {
    [render seekToTarget:@"00:00:11" Unit:unitREL_TIME];
}

- (IBAction)pro:(id)sender {
    [render previous];
}

- (IBAction)next:(id)sender {
    [render next];
}

- (IBAction)getPosition:(id)sender {
    [render getPositionInfo];
}

- (IBAction)getTransport:(id)sender {
    [render getTransportInfo];
}

- (IBAction)subV:(id)sender {
    [render setVolumeWith:@"0"];
}

- (IBAction)addV:(id)sender {
    [render setVolumeWith:@"25"];
}

#pragma mark -
#pragma mark - CLUPnPResponseDelegate -
- (void)upnpSetAVTransportURIResponse{
    //    [render play];
}

- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info{
    //    STOPPED
    //    PAUSED_PLAYBACK
    NSLog(@"%@ === %@", info.currentTransportState, info.currentTransportStatus);
    if (!([info.currentTransportState isEqualToString:@"PLAYING"] || [info.currentTransportState isEqualToString:@"TRANSITIONING"])) {
        [render play];
    }
}

- (void)upnpPlayResponse{
    NSLog(@"播放");
}

- (void)upnpPauseResponse{
    NSLog(@"暂停");
}

- (void)upnpStopResponse{
    NSLog(@"停止");
}

- (void)upnpSeekResponse{
    NSLog(@"跳转完成");
}

- (void)upnpPreviousResponse{
    NSLog(@"前一个");
}

- (void)upnpNextResponse{
    NSLog(@"下一个");
    [render setNextAVTransportURI:urlStr2];
}

- (void)upnpSetVolumeResponse{
    NSLog(@"设置音量成功");
}

- (void)upnpSetNextAVTransportURIResponse{
    NSLog(@"设置下一个url成功");
}

- (void)upnpGetVolumeResponse:(NSString *)volume{
    NSLog(@"音量=%@", volume);
}

- (void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info{
    NSLog(@"%f, === %f === %f", info.trackDuration, info.absTime, info.relTime);
}

- (void)upnpUndefinedResponse:(NSString *)xmlString{
    NSLog(@"xmlString = %@", xmlString);
}


@end
