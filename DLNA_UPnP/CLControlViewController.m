//
//  CLControlViewController.m
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/10/8.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLControlViewController.h"

@interface CLControlViewController ()<CLUPnPRemdererDelegate>{
    BOOL _isPlaying;
    CLUPnPRenderer *render;
}

@end

@implementation CLControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    render = [[CLUPnPRenderer alloc] initWithModel:self.model];
    render.delegate = self;
    [render setAVTransportURL:@"http://v.tiaooo.com/llbizosAzGhJPXC0H4AHLTGHl42W"];
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
#pragma mark - CLUPnPRemdererDelegate -
- (void)getPositionWithXMLElement:(GDataXMLElement *)element{
    NSLog(@"%@", element);
}

- (void)getTransportWithXMLElement:(GDataXMLElement *)element{
    NSLog(@"%@", element);
}

- (void)getVolumeWithXMLElement:(GDataXMLElement *)element{
    NSLog(@"%@", element);
}


@end
