//
//  CLUdpAssociation.h
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@class CLUPnPModel;
@protocol CLUdpAssociationDelegate <NSObject>

- (void)updSearchResultsWith:(CLUPnPModel *)model;

@end

@interface CLUdpAssociation : NSObject<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *udpSocket;
}

@property (nonatomic,weak) id<CLUdpAssociationDelegate>delegate;


/**
 搜索
 */
- (void)search;

/**
 停止
 */
- (void)stop;

@end
