//
//  CLWebView.m
//  CLBasicWebViewController
//
//  Created by chen liang on 2017/8/19.
//  Copyright © 2017年 chen liang. All rights reserved.
//

#import "CLWebView.h"

@implementation CLWebView

- (WKNavigation *)goBack {
    
    self.backNavigation = [super goBack];
    return self.backNavigation;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
