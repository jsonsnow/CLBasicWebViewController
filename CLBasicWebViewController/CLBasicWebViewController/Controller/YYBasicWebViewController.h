//
//  YYBasicWebViewController.h
//  优悦一族
//
//  Created by liang on 2017/5/24.
//  Copyright © 2017年 umed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "CLWebView.h"

typedef NS_ENUM(NSUInteger,YYWebviewRequestType) {
    
    YYWebviewRequestTypeGet,
    YYWebviewRequestTypePost
};

@protocol YYWebViewDataSource <NSObject>

@required;
- (NSString *)methodName;

@optional;
- (YYWebviewRequestType)webViewReqeustType;
- (NSDictionary *)webViewParmas;
- (NSString *)navcTitle;

@end

/**
 加载webView的控制器继承于它
 */
@interface YYBasicWebViewController : UIViewController<WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate>
@property (nonatomic, weak) NSObject <YYWebViewDataSource> *child;
@property (nonatomic, strong) CLWebView *webView;
@property (nonatomic, strong) NSMutableArray *scriptArray;//增加的监听js方法
@property (nonatomic, strong) NSURLRequest *cureqeust;//几当前的request

- (void)setContentView;

// 设置加载网页进度条的frame
- (CGRect)progressViewFrame;

- (void)webViewDidClick;

@end
