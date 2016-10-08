//
//  CLUdpAssociation.m
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLUdpAssociation.h"
#import "CLUPnPModel.h"
#import "GDataXMLNode.h"
#import "CLUPnP.h"

@implementation CLUdpAssociation{
    NSTimer *_timer;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

- (NSString *)getSearchString{
    return [NSString stringWithFormat:@"M-SEARCH * HTTP/1.1\r\nHOST: %@:%d\r\nMAN: \"ssdp:discover\"\r\nMX: 3\r\nST: %@\r\nUSER-AGENT: iOS UPnP/1.1 TestApp/1.0\r\n\r\n", ssdpAddres, ssdpPort, serviceAVTransport];
}

- (void)search{
    NSError *error;
    NSData * sendData = [[self getSearchString] dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:sendData toHost:ssdpAddres port:ssdpPort withTimeout:0 tag:0];
    [udpSocket bindToPort:ssdpPort error:&error];
    [udpSocket joinMulticastGroup:ssdpAddres error:&error];
    [udpSocket beginReceiving:&error];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:15];
    [_timer invalidate];
    _timer = nil;
    _timer = [[NSTimer alloc] initWithFireDate:date interval:1 target:self selector:@selector(stop) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stop{
    [udpSocket close];
    [_timer invalidate];
    _timer = nil;
}

#pragma mark -
#pragma mark -- GCDAsyncUdpSocketDelegate --
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"发送信息成功");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error{
    NSLog(@"发送信息失败, %@", error);
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error{
    NSLog(@"udpSocket关闭");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext{
    NSURL *location = [self deviceUrlWithData:data];
    if (location) {
        [self getUPnPInfoWithLocation:location];
    }
}

// 解析搜索设备获取Location
- (NSURL *)deviceUrlWithData:(NSData *)data{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *subArray = [string componentsSeparatedByString:@"\n"];
    for (int j = 0 ; j < subArray.count; j++){
        NSArray *dicArray = [subArray[j] componentsSeparatedByString:@": "];
        if ([dicArray[0] isEqualToString:@"LOCATION"] || [dicArray[0] isEqualToString:@"Location"]) {
            if (dicArray.count > 1) {
                NSString *location = dicArray[1];
                location = [location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSURL *url = [NSURL URLWithString:location];
                return url;
            }
        }
    }
    return nil;
}

// 获取UPnP信息
- (void)getUPnPInfoWithLocation:(NSURL *)url{
    NSLog(@"location == %@", url);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest  *request=[NSURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(error || data == nil){
                NSLog(@"错误:%@,请重试",error);
                return;
            }else{
                CLUPnPModel *model = [[CLUPnPModel alloc] init];
                model.urlHeader = [NSString stringWithFormat:@"%@://%@:%@", [url scheme], [url host], [url port]];
                NSString *_dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:_dataStr options:0 error:nil];
                GDataXMLElement *xmlEle = [xmlDoc rootElement];
                NSArray *BigArray = [xmlEle children];
                
                for (int i = 0; i < [BigArray count]; i++) {
                    GDataXMLElement *element = [BigArray objectAtIndex:i];
                    
                    if ([[element name] isEqualToString:@"device"]) {
                        NSArray *array = [element children];
                        for (int j = 0; j < [array count]; j++) {
                            GDataXMLElement *ele = [array objectAtIndex:j];
                            if ([ele.name isEqualToString:@"friendlyName"]) {
                                model.friendlyName = [ele stringValue];
                            }
                            if ([ele.name isEqualToString:@"serviceList"]) {
                                NSArray *serviceListArray = [ele children];
                                for (int k = 0; k < [serviceListArray count]; k++) {
                                    GDataXMLElement *listEle = [serviceListArray objectAtIndex:k];
                                    if ([listEle.name isEqualToString:@"service"]) {
                                        if ([[listEle stringValue] rangeOfString:serviceAVTransport].location != NSNotFound) {
                                            [model.AVTransport setArray:[listEle children]];
                                        }else if ([[listEle stringValue] rangeOfString:serviceRenderingControl].location != NSNotFound){
                                            [model.RenderingControl setArray:[listEle children]];
                                        }
                                    }
                                }
                                continue;
                            }
                        }
                        continue;
                    }
                }
                if (model.AVTransport.controlURL) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.delegate respondsToSelector:@selector(updSearchResultsWith:)]) {
                            [self.delegate updSearchResultsWith:model];
                        }
                    });
                }
            }
        }];
        // 执行任务
        [dataTask resume];
    });
}

@end
