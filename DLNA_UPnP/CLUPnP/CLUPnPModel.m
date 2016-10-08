
//
//  CLUPnPModel.m
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLUPnPModel.h"
#import "GDataXMLNode.h"

@implementation CLServiceModel

- (void)setArray:(NSArray *)array{
    for (int m = 0; m < array.count; m++) {
        GDataXMLElement *needEle = [array objectAtIndex:m];
        if ([needEle.name isEqualToString:@"serviceType"]) {
            self.serviceType = [needEle stringValue];
        }
        if ([needEle.name isEqualToString:@"serviceId"]) {
            self.serviceId = [needEle stringValue];
        }
        if ([needEle.name isEqualToString:@"controlURL"]) {
            self.controlURL = [needEle stringValue];
        }
        if ([needEle.name isEqualToString:@"eventSubURL"]) {
            self.eventSubURL = [needEle stringValue];
        }
        if ([needEle.name isEqualToString:@"SCPDURL"]) {
            self.SCPDURL = [needEle stringValue];
        }
    }
}

@end


@implementation CLUPnPModel

- (instancetype)init{
    self = [super init];
    if (self) {
        self.AVTransport = [[CLServiceModel alloc] init];
        self.RenderingControl = [[CLServiceModel alloc] init];
    }
    return self;
}

@end
