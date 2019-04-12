# DLNA_UPnP
基于DLNA实现iOS投屏，SSDP发现设备及SOAP控制设备

## Installation
```一. local pod 导入
在Build Phases->link binary with libraries,添加libxml2.tbd

二. 导入 CLUPnP 文件夹
文件下包含 GDataXMLNode

GDataXMLNode的使用需要注意：
a.在Build Phases->link binary with libraries,添加libxml2.tbd

b.在Build Setting->header search path,添加/usr/include/libxml2 路径

c.在Build Phases->compile sources -> GDataXMLNode.m, ARC编译MRC加 -fno-objc-arc
```

## Using
``` 1.搜索设备 CLUPnPServer.h  

// 搜索
- (void)start;
// 停止
- (void)stop;

[协议 CLUPnPServerDelegate]
回调方法：
@required
/**
搜索结果

@param devices 设备数组
*/
- (void)upnpSearchChangeWithResults:(NSArray <CLUPnPDevice *>*)devices;

@optional

- (void)upnpSearchErrorWithError:(NSError *)error;       // 搜索失败

2.控制设备 CLUPnPRenderer.h

// 初始化 model:搜索得到的UPnPModel
- (instancetype)initWithModel:(CLUPnPModel *)model;

// 投屏 urlStr:视频url
- (void)setAVTransportURL:(NSString *)urlStr;

// 设置下一个播放地址 urlStr:下一个视频url
- (void)setNextAVTransportURI:(NSString *)urlStr;

// 播放
- (void)play;

// 暂停
- (void)pause;

// 结束
- (void)stop;

// 下一个
- (void)next;

// 前一个
- (void)previous;

// 跳转进度
// relTime 进度时间(单位秒)
- (void)seek:(float)relTime;

// 跳转至特定进度或视频
// target 目标值，可以是 00:02:21 格式的进度或者整数的 TRACK_NR。
// unit   REL_TIME（跳转到某个进度）或 TRACK_NR（跳转到某个视频）。
- (void)seekToTarget:(NSString *)target Unit:(NSString *)unit;

// 获取播放进度,可通过协议回调使用
- (void)getPositionInfo;

// 获取播放状态,可通过协议回调使用
- (void)getTransportInfo;

// 获取音频,可通过协议回调使用
- (void)getVolume;

// 设置音频值 value->整数字符串
- (void)setVolumeWith:(NSString *)value;


[协议 CLUPnPResponseDelegate]
回调方法：
@required
- (void)upnpSetAVTransportURIResponse;      // 设置url响应
- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info;   // 获取播放状态

@optional
- (void)upnpPlayResponse;                   // 播放响应
- (void)upnpPauseResponse;                  // 暂停响应
- (void)upnpStopResponse;                   // 停止投屏
- (void)upnpSeekResponse;                   // 跳转响应
- (void)upnpPreviousResponse;               // 以前的响应
- (void)upnpNextResponse;                   // 下一个响应
- (void)upnpSetVolumeResponse;              // 设置音量响应
- (void)upnpSetNextAVTransportURIResponse;  // 设置下一个url响应
- (void)upnpGetVolumeResponse:(NSString *)volume;                   // 获取音频信息
- (void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info;   // 获取播放进度
- (void)upnpUndefinedResponse:(NSString *)resXML postXML:(NSString *)postXML;                // 未定义的响应/错误

```

## References

感谢作者[Eliyar's Blog](https://eliyar.biz)的两篇博客
* [基于DLNA实现iOS，Android投屏：SSDP发现设备](https://eliyar.biz/DLNA_with_iOS_Android_Part_1_Find_Device_Using_SSDP/)
* [基于DLNA实现iOS，Android投屏：SOAP控制设备](https://eliyar.biz/DLNA_with_iOS_Android_Part_2_Control_Using_SOAP/)

这两篇博客讲的很清楚 我就不多说了 需要的朋友可以看看。

## Author

ClaudeLi, claudeli@yeah.net

## License

DLNA_UPnP is available under the MIT license. See the LICENSE file for more info.
