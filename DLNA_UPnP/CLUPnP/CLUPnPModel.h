//
//  CLUPnPModel.h
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLServiceModel : NSObject

@property (nonatomic, copy) NSString *serviceType;
@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *controlURL;
@property (nonatomic, copy) NSString *eventSubURL;
@property (nonatomic, copy) NSString *SCPDURL;

- (void)setArray:(NSArray *)array;

@end

@interface CLUPnPModel : NSObject

@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *modelName;

@property (nonatomic, copy) NSString *urlHeader;

@property (nonatomic, strong) CLServiceModel *AVTransport;
@property (nonatomic, strong) CLServiceModel *RenderingControl;

- (void)setArray:(NSArray *)array;

@end



