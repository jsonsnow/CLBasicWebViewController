//
//  CLWebView.h
//  CLBasicWebViewController
//
//  Created by chen liang on 2017/8/19.
//  Copyright © 2017年 chen liang. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface CLWebView : WKWebView
@property (nonatomic, weak) WKNavigation *backNavigation;//点击返回的时候，WK对应的导航

@end
