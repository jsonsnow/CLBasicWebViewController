//
//  YYBasicWebViewController+YYJS2OCBridge.m
//  优悦一族
//
//  Created by liang on 2017/5/26.
//  Copyright © 2017年 umed. All rights reserved.
//

#import "YYBasicWebViewController+YYJS2OCBridge.h"

@implementation YYBasicWebViewController (YYJS2OCBridge)

- (void)addScriptMessageHandler:(NSString *)name {
    // WKUserContentController, 内容交互控制器，通过JS与Webview内容交互
    // 发送消息
    // 比如，JS要调用原生的方法，就可以通过这种方式
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:name];
    [self.scriptArray addObject:name];
}

/// OC调用JavaScript代码
- (void)callScriptMethod:(NSString *)method params:(id)params {
    
    if ([params isKindOfClass:[NSString class]]) {
        
        NSString *param = params;
        method = [NSString stringWithFormat:@"%@(\'%@\')",method,param];
#ifdef DEBUG
        NSLog(@"method:%@",method);
#endif
        [self.webView evaluateJavaScript:method completionHandler:nil];
    } else {
        
        if (!params) {
            
            method = method;
        } else
             method = [NSString stringWithFormat:@"%@(%@)",method,params];
        [self.webView evaluateJavaScript:method completionHandler:nil];
#ifdef DEBUG
        NSLog(@"method:%@",method);
#endif
    }
}

- (void)removelScript:(NSString *)name {
    
    if ([self.scriptArray containsObject:name]) {
        
        [self.scriptArray removeObject:name];
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:name];
    }
}

- (void)removeAllScript {
    
    [self.scriptArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSString *name = obj;
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:name];
    }];
    [self.scriptArray removeAllObjects];
}
@end
