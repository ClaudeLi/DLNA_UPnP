//
//  CLUPnPRenderer.m
//  Tiaooo
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLUPnP.h"
#import "GDataXMLNode.h"
#import "CLUPnPAction.h"

@implementation CLUPnPRenderer

- (instancetype)initWithModel:(CLUPnPModel *)model{
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)setModel:(CLUPnPModel *)model{
    _model = model;
}

#pragma mark -
#pragma mark -- AVTransport动作 --
- (void)setAVTransportURL:(NSString *)urlStr{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"SetAVTransportURI"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:urlStr forName:@"CurrentURI"];
    [action setArgumentValue:@"" forName:@"CurrentURIMetaData"];
    [self postRequestWith:action];
}

- (void)setNextAVTransportURI:(NSString *)urlStr{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"SetNextAVTransportURI"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:urlStr forName:@"NextURI"];
    [action setArgumentValue:@"" forName:@"NextURIMetaData"];
    [self postRequestWith:action];
}

- (void)play{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Play"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"1" forName:@"Speed"];
    [self postRequestWith:action];
}

- (void)pause{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Pause"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)stop{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Stop"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)next{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Next"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)previous{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Previous"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)getPositionInfo{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"GetPositionInfo"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)getTransportInfo{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"GetTransportInfo"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)seek:(float)relTime{
    [self seekToTarget:[NSString stringWithDurationTime:relTime] Unit:unitREL_TIME];
}

- (void)seekToTarget:(NSString *)target Unit:(NSString *)unit{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Seek"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:unit forName:@"Unit"];
    [action setArgumentValue:target forName:@"Target"];
    [self postRequestWith:action];
}

#pragma mark -
#pragma mark -- RenderingControl动作 --
- (void)getVolume{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"GetVolume"];
    [action setServiceType:CLUPnPServiceRenderingControl];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"Master" forName:@"Channel"];
    [self postRequestWith:action];
}

- (void)setVolumeWith:(NSString *)value{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"SetVolume"];
    [action setServiceType:CLUPnPServiceRenderingControl];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"Master" forName:@"Channel"];
    [action setArgumentValue:value forName:@"DesiredVolume"];
    [self postRequestWith:action];
}

#pragma mark -
#pragma mark -- 发送动作请求 --
- (void)postRequestWith:(CLUPnPAction *)action{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[action getPostUrlStrWith:_model]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[action getSOAPAction] forHTTPHeaderField:@"SOAPAction"];
    request.HTTPBody = [[action getPostXMLFile] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || data == nil) {
            CLLog(@"error=%@", error);
            [self _UndefinedResponse:[action getPostXMLFile]];
            return;
        }else{
            [self parseRequestResponseData:data];
        }
    }];
    [dataTask resume];
}

#pragma mark -
#pragma mark -- 动作响应 --
- (void)parseRequestResponseData:(NSData *)data{
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *bigArray = [xmlEle children];
    for (int i = 0; i < [bigArray count]; i++) {
        GDataXMLElement *element = [bigArray objectAtIndex:i];
        NSArray *needArr = [element children];
        if ([[element name] hasSuffix:@"Body"]) {
            [self resultsWith:needArr];
        }else{
            [self _UndefinedResponse:[xmlEle XMLString]];
        }
    }
}

- (void)resultsWith:(NSArray *)array{
    for (int i = 0; i < array.count; i++) {
        GDataXMLElement *ele = [array objectAtIndex:i];
        if ([[ele name] hasSuffix:@"SetAVTransportURIResponse"]) {
            [self _SetAVTransportURIResponse];
            [self getTransportInfo];
        }else if ([[ele name] hasSuffix:@"SetNextAVTransportURIResponse"]){
            [self _SetNextAVTransportURIResponse];
        }else if ([[ele name] hasSuffix:@"PauseResponse"]){
            [self _PauseResponse];
        }else if ([[ele name] hasSuffix:@"PlayResponse"]){
            [self _PlayResponse];
        }else if ([[ele name] hasSuffix:@"StopResponse"]){
            [self _StopResponse];
        }else if ([[ele name] hasSuffix:@"SeekResponse"]){
            [self _SeekResponse];
        }else if ([[ele name] hasSuffix:@"NextResponse"]){
            [self _NextResponse];
        }else if ([[ele name] hasSuffix:@"PreviousResponse"]){
            [self _PreviousResponse];
        }else if ([[ele name] hasSuffix:@"SetVolumeResponse"]){
            [self _SetVolumeResponse];
        }else if ([[ele name] hasSuffix:@"GetVolumeResponse"]){
            [self _GetVolumeSuccessWith:[ele children]];
        }else if ([[ele name] hasSuffix:@"GetPositionInfoResponse"]){
            [self _GetPositionInfoResponseWith:[ele children]];
        }else if ([[ele name] hasSuffix:@"GetTransportInfoResponse"]){
            [self _GetTransportInfoResponseWith:[ele children]];
        }else{
            [self _UndefinedResponse:[ele XMLString]];
        }
    }
}

#pragma mark -
#pragma mark -- 回调协议 --
- (void)_SetAVTransportURIResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSetAVTransportURIResponse)]) {
        [self.delegate upnpSetAVTransportURIResponse];
    }
}

- (void)_SetNextAVTransportURIResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSetNextAVTransportURIResponse)]) {
        [self.delegate upnpSetNextAVTransportURIResponse];
    }
}

- (void)_PauseResponse{
    if ([self.delegate respondsToSelector:@selector(upnpPauseResponse)]) {
        [self.delegate upnpPauseResponse];
    }
}

- (void)_PlayResponse{
    if ([self.delegate respondsToSelector:@selector(upnpPlayResponse)]) {
        [self.delegate upnpPlayResponse];
    }
}

- (void)_StopResponse{
    if ([self.delegate respondsToSelector:@selector(upnpStopResponse)]) {
        [self.delegate upnpStopResponse];
    }
}

- (void)_SeekResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSeekResponse)]) {
        [self.delegate upnpSeekResponse];
    }
}

- (void)_NextResponse{
    if ([self.delegate respondsToSelector:@selector(upnpNextResponse)]) {
        [self.delegate upnpNextResponse];
    }
}

- (void)_PreviousResponse{
    if ([self.delegate respondsToSelector:@selector(upnpPreviousResponse)]) {
        [self.delegate upnpPreviousResponse];
    }
}

- (void)_SetVolumeResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSetVolumeResponse)]) {
        [self.delegate upnpSetVolumeResponse];
    }
}

- (void)_GetVolumeSuccessWith:(NSArray *)array{
    for (int j = 0; j < array.count; j++) {
        GDataXMLElement *eleXml = [array objectAtIndex:j];
        if ([[eleXml name] isEqualToString:@"CurrentVolume"]) {
            if ([self.delegate respondsToSelector:@selector(upnpGetVolumeResponse:)]) {
                [self.delegate upnpGetVolumeResponse:[eleXml stringValue]];
            }
        }
    }
}

- (void)_GetPositionInfoResponseWith:(NSArray *)array{
    CLUPnPAVPositionInfo *info = [[CLUPnPAVPositionInfo alloc] init];
    [info setArray:array];
    if ([self.delegate respondsToSelector:@selector(upnpGetPositionInfoResponse:)]) {
        [self.delegate upnpGetPositionInfoResponse:info];
    }
}

- (void)_GetTransportInfoResponseWith:(NSArray *)array{
    CLUPnPTransportInfo *info = [[CLUPnPTransportInfo alloc] init];
    [info setArray:array];
    if ([self.delegate respondsToSelector:@selector(upnpGetTransportInfoResponse:)]) {
        [self.delegate upnpGetTransportInfoResponse:info];
    }
}

- (void)_UndefinedResponse:(NSString *)xmlStr{
    if ([self.delegate respondsToSelector:@selector(upnpUndefinedResponse:)]) {
        [self.delegate upnpUndefinedResponse:xmlStr];
    }
}

@end
