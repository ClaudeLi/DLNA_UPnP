//
//  CLUPnPDevice.h
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/10/10.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@class CLUPnPModel;
@protocol CLUPnPDeviceDelegate <NSObject>
@required

- (void)upnpSearchResultsWith:(CLUPnPModel *)model; // 搜索结果

@optional

- (void)upnpSearchErrorWith:(NSError *)error;       // 搜索失败

@end

@interface CLUPnPDevice : NSObject<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *udpSocket;
}

@property (nonatomic,weak) id<CLUPnPDeviceDelegate>delegate;

/**
 搜索
 */
- (void)search;

/**
 停止
 */
- (void)stop;


@end
