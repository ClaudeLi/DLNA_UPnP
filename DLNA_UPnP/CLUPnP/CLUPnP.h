//
//  CLUPnP.h
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#ifndef CLUPnP_h
#define CLUPnP_h

#import "CLUdpAssociation.h"
#import "CLUPnPRenderer.h"
#import "GDataXMLNode.h"
#import "CLUPnPModel.h"

static NSString *ssdpAddres = @"239.255.255.250";
static UInt16   ssdpPort = 1900;

static NSString *serviceAVTransport         = @"urn:schemas-upnp-org:service:AVTransport:1";
static NSString *serviceRenderingControl    = @"urn:schemas-upnp-org:service:RenderingControl:1";

static NSString *unitREL_TIME = @"REL_TIME";
static NSString *unitTRACK_NR = @"TRACK_NR";

#endif /* CLUPnP_h */
