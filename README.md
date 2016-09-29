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
        // 搜索方法
        - (void)search;
        // 停止
        - (void)stop;
        
        回调协议 CLUdpAssociationDelegate
        - (void)updSearchResultsWith:(CLUPnPModel *)model;

3.控制设备 CLUPnPRenderer.h
        // 初始化
        - (instancetype)initWithModel:(CLUPnPModel *)model;
        // 投屏 视频url
        - (void)setAVTransportURL:(NSString *)urlStr;
        // 播放
        - (void)play;
        // 暂停
        - (void)pause;

感谢
==============
[Eliyar's Blog](https://eliyar.biz)
* [基于DLNA实现iOS，Android投屏：SSDP发现设备](https://eliyar.biz/DLNA_with_iOS_Android_Part_1_Find_Device_Using_SSDP/)
* [基于DLNA实现iOS，Android投屏：SOAP控制设备](https://eliyar.biz/DLNA_with_iOS_Android_Part_2_Control_Using_SOAP/)

这两篇博客讲的很清楚 我就不多说了 需要的朋友可以看看。
