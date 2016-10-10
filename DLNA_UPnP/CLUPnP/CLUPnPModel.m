
//
//  CLUPnPModel.m
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLUPnP.h"
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

- (void)setArray:(NSArray *)array{
    for (int j = 0; j < [array count]; j++) {
        GDataXMLElement *ele = [array objectAtIndex:j];
        if ([ele.name isEqualToString:@"friendlyName"]) {
            self.friendlyName = [ele stringValue];
        }
        if ([ele.name isEqualToString:@"modelName"]) {
            self.modelName = [ele stringValue];
        }
        if ([ele.name isEqualToString:@"serviceList"]) {
            NSArray *serviceListArray = [ele children];
            for (int k = 0; k < [serviceListArray count]; k++) {
                GDataXMLElement *listEle = [serviceListArray objectAtIndex:k];
                if ([listEle.name isEqualToString:@"service"]) {
                    if ([[listEle stringValue] rangeOfString:serviceAVTransport].location != NSNotFound) {
                        [self.AVTransport setArray:[listEle children]];
                    }else if ([[listEle stringValue] rangeOfString:serviceRenderingControl].location != NSNotFound){
                        [self.RenderingControl setArray:[listEle children]];
                    }
                }
            }
            continue;
        }
    }
}


@end
