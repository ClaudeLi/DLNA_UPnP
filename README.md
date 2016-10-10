# DLNA_UPnP
基于DLNA实现iOS投屏，SSDP发现设备及SOAP控制设备


### 使用方法:
1.导入工程的 CLUPnP 文件夹。

文件下包含的第三方类有[GCDAsyncUdpSocket](https://github.com/robbiehanson/CocoaAsyncSocket), GDataXMLNode

        GDataXMLNode的使用需要注意：
            a.在Build Phases->link binary with libraries,添加libxml2.tbd
            
            b.在Build Setting->header search path,添加/usr/include/libxml2 路径
            
            c.在Build Phases->compile sources -> GDataXMLNode.m, ARC编译MRC加 -fno-objc-arc

2.搜索设备 CLUdpAssociation.h <有bug待改进> 
        
        // 搜索
        - (void)search;
        // 停止
        - (void)stop;
        
        [协议 CLUdpAssociationDelegate]
        回调方法：
        @required
        - (void)upnpSearchResultsWith:(CLUPnPModel *)model; // 搜索结果
        @optional
        - (void)upnpSearchErrorWith:(NSError *)error;       // 搜索失败

3.控制设备 CLUPnPRenderer.h
        
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
        
        // 获取播放进度,若想使用需要通过协议回调解析xml
        - (void)getPositionInfo;
        
        // 获取播放状态,若想使用需要通过协议回调解析xml
        - (void)getTransportInfo;
        
        // 获取音频，若想使用需要通过协议回调解析xml
        - (void)getVolume;
        
        // 设置音频值 value->整数字符串
        - (void)setVolumeWith:(NSString *)value;

        
        [协议 CLUPnPRemdererDelegate]
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
        - (void)upnpUndefinedResponse:(NSString *)xmlString;                // 未定义的响应/错误


==============
感谢[Eliyar's Blog](https://eliyar.biz)
* [基于DLNA实现iOS，Android投屏：SSDP发现设备](https://eliyar.biz/DLNA_with_iOS_Android_Part_1_Find_Device_Using_SSDP/)
* [基于DLNA实现iOS，Android投屏：SOAP控制设备](https://eliyar.biz/DLNA_with_iOS_Android_Part_2_Control_Using_SOAP/)

这两篇博客讲的很清楚 我就不多说了 需要的朋友可以看看。
