//
//  YYBasicWebViewController+YYJS2OCBridge.h
//  CLBasicWebViewController
//
//  Created by liang on 2017/5/26.
//  Copyright © 2017年 umed. All rights reserved.
//

#import "YYBasicWebViewController.h"

@interface YYBasicWebViewController (YYJS2OCBridge)

- (void)addScriptMessageHandler:(NSString *)name;

- (void)callScriptMethod:(NSString *)method params:(id)params;

- (void)removelScript:(NSString *)name;

- (void)removeAllScript;
@end
