//
//  CLUPnPAction.m
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/10/10.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLUPnPAction.h"
#import "GDataXMLNode.h"
#import "CLUPnP.h"

@interface CLUPnPAction (){
        NSString    *_action;
}
@property (nonatomic, strong) GDataXMLElement *XMLElement;

@end

@implementation CLUPnPAction

- (instancetype)initWithAction:(NSString *)action{
    self = [super init];
    if (self) {
        _action = action;
        _serviceType = CLUPnPServiceAVTransport;
        NSString *name = [NSString stringWithFormat:@"u:%@", _action];
        self.XMLElement = [GDataXMLElement elementWithName:name];
    }
    return self;
}

- (void)setServiceType:(CLUPnPServiceType)serviceType{
    _serviceType = serviceType;
}

- (void)setArgumentValue:(NSString *)value forName:(NSString *)name{
    [self.XMLElement addChild:[GDataXMLElement elementWithName:name stringValue:value]];
}

- (NSString *)getServiceType{
    if (_serviceType == CLUPnPServiceAVTransport) {
        return serviceAVTransport;
    }else{
        return serviceRenderingControl;
    }
}

- (NSString *)getSOAPAction{
    if (_serviceType == CLUPnPServiceAVTransport) {
        return [NSString stringWithFormat:@"\"%@#%@\"", serviceAVTransport, _action];
    }else{
        return [NSString stringWithFormat:@"\"%@#%@\"", serviceRenderingControl, _action];
    }
}

- (NSString *)getPostUrlStrWith:(CLUPnPModel *)model{
    if (_serviceType == CLUPnPServiceAVTransport) {
        return [self getUPnPURLWithUrlModel:model.AVTransport urlHeader:model.urlHeader];
    }else{
        return [self getUPnPURLWithUrlModel:model.RenderingControl urlHeader:model.urlHeader];;
    }
}

- (NSString *)getUPnPURLWithUrlModel:(CLServiceModel *)model urlHeader:(NSString *)urlHeader{
    if ([[model.controlURL substringToIndex:1] isEqualToString:@"/"]) {
        return [NSString stringWithFormat:@"%@%@", urlHeader, model.controlURL];
    }else{
        return [NSString stringWithFormat:@"%@/%@", urlHeader, model.controlURL];
    }
}

- (NSString *)getPostXMLFile{
    GDataXMLElement *xmlEle = [GDataXMLElement elementWithName:@"s:Envelope"];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"s:encodingStyle" stringValue:@"http://schemas.xmlsoap.org/soap/encoding/"]];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"xmlns:s" stringValue:@"http://schemas.xmlsoap.org/soap/envelope/"]];
    [xmlEle addChild:[GDataXMLElement attributeWithName:@"xmlns:u" stringValue:[self getServiceType]]];
    GDataXMLElement *command = [GDataXMLElement elementWithName:@"s:Body"];
    [command addChild:self.XMLElement];
    [xmlEle addChild:command];
    return xmlEle.XMLString;
}

@end
