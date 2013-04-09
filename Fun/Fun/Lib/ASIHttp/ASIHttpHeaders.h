//
//  ASIHttpHeaders.h
//
//  Created by andone on 10-10-9.
//  Copyright 2010 szu. All rights reserved.
//



#import "ASIAuthenticationDialog.h"//该类允许ASIHTTPRequest连接到服务器时呈现登录框。在所有iPhone OS工程中都要使用，Mac OS工程中可以不用。
#import "ASICacheDelegate.h"//该协议指定了download cache必须实现的方法。如果你要写你自己的download cache，确保实现required方法。
//#import "ASIDataCompressor.h"
//#import "ASIDataDecompressor.h"
#import "ASIDownloadCache.h"//该类允许ASIHTTPRequest从服务器传递cookie。
#import "ASIFormDataRequest.h"//是ASIHTTPRequest子类，主要处理post事件，它能使post更加简单。
#import "ASIHTTPRequest.h"//处理与服务器的基本交互，包括下载上传，认证，cookies以及进度查看。
#import "ASIHTTPRequestConfig.h"//该文件定义了编译时所有的全局配置选项。
#import "ASIHTTPRequestDelegate.h"//该协议指定了ASIHTTPRequest的delegate可能需要实现的方法，所有方法都是optional。
#import "ASIInputStream.h"//当使用ASIHTTPRequest上传数据时使用，如果工程中用了ASIHTTPRequest，就一定要include这个类。
#import "ASINetworkQueue.h"//是NSOperationQueue子类，当处理多个请求时可以使用，如果每次都是单个请求就不必使用。
#import "ASIProgressDelegate.h"//该协议列出了uploadProgressDelegate和downloadProgressDelegate可能需要实现的方法，所有方法为optional。
#import "PKReachability.h"//相信很多人对这个类已经很熟悉了，当在你程序中侦测网络状态时它将非常有用。
