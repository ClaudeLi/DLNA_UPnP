
//
//  CLUPnPModel.m
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLUPnPModel.h"

@implementation CLUPnPModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqual:@""]) {
        
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

@end
