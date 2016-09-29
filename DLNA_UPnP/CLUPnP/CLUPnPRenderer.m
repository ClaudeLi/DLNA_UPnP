//
//  CLUPnPRenderer.m
//  Tiaooo
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLUPnPRenderer.h"
#import "GDataXMLNode.h"
#import "CLUPnPModel.h"

@implementation CLUPnPRenderer

- (instancetype)initWithModel:(CLUPnPModel *)model{
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

#pragma mark -
#pragma mark -- 构造动作XML --
- (NSString *)prepareXMLFileWithCommand:(GDataXMLElement *)xml{
    GDataXMLElement *xmlEle = [GDataXMLElement elementWithName:@"s:Envelope"];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"s:encodingStyle" stringValue:@"http://schemas.xmlsoap.org/soap/encoding/"]];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"xmlns:s" stringValue:@"http://schemas.xmlsoap.org/soap/envelope/"]];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"xmlns:u" stringValue:@"urn:schemas-upnp-org:service:AVTransport:1"]];
    GDataXMLElement *command = [GDataXMLElement elementWithName:@"s:Body"];
    [command addChild:xml];
    [xmlEle addChild:command];
    return xmlEle.XMLString;
}

// 投屏 视频url
- (void)setAVTransportURL:(NSString *)urlStr{
    GDataXMLElement *command = [GDataXMLElement elementWithName:@"u:SetAVTransportURI"];
    [command addChild:[GDataXMLElement attributeWithName:@"xmlns:u" stringValue:@"urn:schemas-upnp-org:service:AVTransport:1"]];
    [command addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [command addChild:[GDataXMLElement elementWithName:@"CurrentURI" stringValue:urlStr]];
    [command addChild:[GDataXMLElement elementWithName:@"CurrentURIMetaData"]];
    NSString *xmlStr = [self prepareXMLFileWithCommand:command];
    [self sendRequestWithData:xmlStr action:@"SetAVTransportURI"];
}

// 播放视频
- (void)play{
    GDataXMLElement *command = [GDataXMLElement elementWithName:@"u:Play"];
    [command addChild:[GDataXMLElement attributeWithName:@"xmlns:u" stringValue:@"urn:schemas-upnp-org:service:AVTransport:1"]];
    [command addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [command addChild:[GDataXMLElement elementWithName:@"Speed" stringValue:@"1"]];
    NSString *xmlStr = [self prepareXMLFileWithCommand:command];
    [self sendRequestWithData:xmlStr action:@"Play"];
}

- (void)pause{
    GDataXMLElement *command = [GDataXMLElement elementWithName:@"u:Pause"];
    [command addChild:[GDataXMLElement attributeWithName:@"xmlns:u" stringValue:@"urn:schemas-upnp-org:service:AVTransport:1"]];
    [command addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [command addChild:[GDataXMLElement elementWithName:@"Speed" stringValue:@"1"]];
    NSString *xmlStr = [self prepareXMLFileWithCommand:command];
    [self sendRequestWithData:xmlStr action:@"Pause"];
}

- (void)seekToTarget:(NSString *)target Unit:(NSString *)unit{
    GDataXMLElement *command = [GDataXMLElement elementWithName:@"u:Seek"];
    [command addChild:[GDataXMLElement attributeWithName:@"xmlns:u" stringValue:@"urn:schemas-upnp-org:service:AVTransport:1"]];
    [command addChild:[GDataXMLElement elementWithName:@"InstanceID" stringValue:@"0"]];
    [command addChild:[GDataXMLElement elementWithName:@"Unit" stringValue:unit]];
    [command addChild:[GDataXMLElement elementWithName:@"Target" stringValue:target]];
    NSString *xmlStr = [self prepareXMLFileWithCommand:command];
    [self sendRequestWithData:xmlStr action:@"Seek"];
}


- (void)sendRequestWithData:(NSString *)xmlStr action:(NSString *)action{
    NSLog(@"xmlStr == %@", xmlStr);
    NSString *SOAPAction = [NSString stringWithFormat:@"\"urn:schemas-upnp-org:service:AVTransport:1#%@\"", action];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *urlString = [self getUPnPURLWithUrlModel:_model];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request addValue:SOAPAction forHTTPHeaderField:@"SOAPAction"];
    request.HTTPBody = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || data == nil) {
            NSLog(@"%@", error);
            return;
        }else{
            [self parseRequestResponseData:data];
        }
    }];
    [dataTask resume];
}

- (NSString *)getUPnPURLWithUrlModel:(CLUPnPModel *)model{
    if ([[model.controlURL substringToIndex:1] isEqualToString:@"/"]) {
        return [NSString stringWithFormat:@"%@%@", model.urlHeader, model.controlURL];
    }else{
        return [NSString stringWithFormat:@"%@/%@", model.urlHeader, model.controlURL];
    }
}

- (void)parseRequestResponseData:(NSData *)data{
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *bigArray = [xmlEle children];
    NSLog(@"响应 == %@", xmlEle.XMLString);
    for (int i = 0; i < [bigArray count]; i++) {
        GDataXMLElement *element = [bigArray objectAtIndex:i];
        NSArray *needArr = [element children];
        if ([[element name] hasSuffix:@"Body"]) {
            [self resultsWith:needArr];
        }else{
            
        }
    }
}

- (void)resultsWith:(NSArray *)array{
    for (int i = 0; i < array.count; i++) {
        GDataXMLElement *ele = [array objectAtIndex:i];
        if ([[ele name] hasSuffix:@"SetAVTransportURIResponse"]) {
            NSLog(@"设置URI成功");
            [self play];
        }else if ([[ele name] hasSuffix:@"GetPositionInfoResponse"]){
            NSLog(@"已获取进度");
        }else if ([[ele name] hasSuffix:@"PauseResponse"]){
            NSLog(@"暂停");
        }else if ([[ele name] hasSuffix:@"PlayResponse"]){
            NSLog(@"播放");
        }else if ([[ele name] hasSuffix:@"StopResponse"]){
            NSLog(@"停止");
        }else if ([[ele name] hasSuffix:@"SeekResponse"]){
            NSLog(@"跳转成功");
        }else{
            NSLog(@"未定义响应");
        }
    }
}

@end
