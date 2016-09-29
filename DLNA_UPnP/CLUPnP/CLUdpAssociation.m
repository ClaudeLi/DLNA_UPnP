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

static NSString *ssdpAddres = @"239.255.255.250";
static UInt16 ssdpPort = 1900;

@implementation CLUdpAssociation

- (instancetype)init{
    self = [super init];
    if (self) {
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

- (void)search{
    NSError *error;
    NSData * sendData = [@"M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 3\r\nST: urn:schemas-upnp-org:service:AVTransport:1\r\nUSER-AGENT: iOS UPnP/1.1 TestApp/1.0\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:sendData toHost:ssdpAddres port:ssdpPort withTimeout:0 tag:0];
    [udpSocket bindToPort:ssdpPort error:&error];
    [udpSocket joinMulticastGroup:ssdpAddres error:&error];
    [udpSocket beginReceiving:&error];
}

- (void)stop{
    [udpSocket close];
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
                                        if ([[listEle stringValue] rangeOfString:@"urn:schemas-upnp-org:service:AVTransport:1"].location != NSNotFound) {
                                            NSArray *needArr = [listEle children];
                                            for (int m = 0; m < needArr.count; m++) {
                                                GDataXMLElement *needEle = [needArr objectAtIndex:m];
                                                if ([needEle.name isEqualToString:@"serviceType"]) {
                                                    model.serviceType = [needEle stringValue];
                                                }
                                                if ([needEle.name isEqualToString:@"serviceId"]) {
                                                    model.serviceId = [needEle stringValue];
                                                }
                                                if ([needEle.name isEqualToString:@"controlURL"]) {
                                                    model.controlURL = [needEle stringValue];
                                                }
                                                if ([needEle.name isEqualToString:@"eventSubURL"]) {
                                                    model.eventSubURL = [needEle stringValue];
                                                }
                                                if ([needEle.name isEqualToString:@"SCPDURL"]) {
                                                    model.SCPDURL = [needEle stringValue];
                                                }
                                            }
                                            continue;
                                        }
                                    }
                                    
                                }
                                continue;
                            }
                        }
                        continue;
                    }
                }
                if (model.controlURL) {
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
