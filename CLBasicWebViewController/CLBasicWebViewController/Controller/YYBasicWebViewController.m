//
//  YYBasicWebViewController.m
//  CLBasicWebViewController
//
//  Created by liang on 2017/5/24.
//  Copyright © 2017年 umed. All rights reserved.
//

#import "YYBasicWebViewController.h"
#import <AFNetworking.h>

@interface YYBasicWebViewController ()
@property (nonatomic, strong) UIProgressView *progress;

@end

@implementation YYBasicWebViewController

#pragma mark - life cycle
- (instancetype)init {
    
    self = [super init];
    if ([self conformsToProtocol:@protocol(YYWebViewDataSource) ]) {
        
        self.child = (id<YYWebViewDataSource>)self;
        
    } else {
        
        NSException *excption = [NSException exceptionWithName:@"error" reason:@"subClass must realize this protocl" userInfo:nil];
        @throw excption;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if ([self conformsToProtocol:@protocol(YYWebViewDataSource) ]) {
        
        self.child = (id<YYWebViewDataSource>)self;
        
    } else {
        
        NSException *excption = [NSException exceptionWithName:@"error" reason:@"subClass must realize this protocl" userInfo:nil];
        @throw excption;
    }
    return self;
}
- (void)awakeFromNib {
    
    [super awakeFromNib];
    if ([self conformsToProtocol:@protocol(YYWebViewDataSource) ]) {
        
        self.child = (id<YYWebViewDataSource>)self;
        
    } else {
        
        NSException *excption = [NSException exceptionWithName:@"error" reason:@"subClass must realize this protocl" userInfo:nil];
        @throw excption;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContentView];
    [self loadData];
    [self addTitleAndProgressObser];
    [self addCangobackOber];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if ([self.child respondsToSelector:@selector(navcTitle)]) {
        
        self.navigationItem.title = [self.child navcTitle];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

    if (self.isViewLoaded) {
        
        [self removeTitleAndProgressObserver];
        [self removeCanGoBackOber];
        if (self.scriptArray.count > 0) {
            
            [self.scriptArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                // 根据name移除所注入的scriptMessageHandler
                NSString *name = obj;
                [self.webView.configuration.userContentController removeScriptMessageHandlerForName:name];
            }];
        }

    }
}

#pragma mark - WKNvcDelegate
// 决定导航的动作，通常用于处理跨域的链接能否导航。WebKit对跨域进行了安全检查限制，不允许跨越，因此要对不能跨域的链接单独处理，但是，对于Safari是允许跨域的，不用这么处理。
// 这个是决定是否Request
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    decisionHandler(WKNavigationActionPolicyAllow);
    self.cureqeust = navigationAction.request;
    
}

// 决定是否接收响应
// 这个是决定是否接收response
// 要获取response，通过WKNavigationResponse对象获取
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {

    [self setCookies:navigationResponse.response];
    decisionHandler(WKNavigationResponsePolicyAllow);

}

// 当 main frame开始加载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    //do nothing, you can show a cover view to hint user
}

// 当main frame导航完成时，会回调
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self reloadWebViewWhenNavigationBack:navigation];
    //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //js函数
    NSString *JSFuncString =
    @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=({FNXX==XXFN}*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";
    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    //执行js代码
    [webView evaluateJavaScript:JSCookieString completionHandler:nil];
  
}
//监听的js代码被执行后会调用，不过需要注意js端的代码必须带有参数
#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    
}

#pragma mark - public method

- (CGRect)progressViewFrame {
    
    return CGRectMake(0, 0, self.view.bounds.size.width, 10);
}

- (void)webViewDidClick {
    
    
}
#pragma mark - private method

- (void)setContentView {
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progress];
    self.progress.frame = [self progressViewFrame];
}

- (void)loadData {
    
    NSString *url = [self requstUrl];
    YYWebviewRequestType type = [self requestType];
    NSDictionary *params = [self requestParams];
    NSURLRequest *reqeust = [self serializeRequestUrl:url methodName:type params:params];
    [self.webView loadRequest:reqeust];
    
}

- (void)addTitleAndProgressObser {
    
    // KVO 当前加载的进度，范围为[0,1]
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    // KVO 页面的标题
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeTitleAndProgressObserver {
    
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

- (void)addCangobackOber {
    
    // KVO 是否支持goBack操作
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeCanGoBackOber {
    
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
}
- (NSString *)requstUrl {
    
    return [self.child methodName];
}

- (NSDictionary *)requestParams {
    
    NSDictionary *params;
    if ([self.child respondsToSelector:@selector(webViewParmas)]) {
        
        
        params = [self.child webViewParmas];
    }
    return params;
}

- (YYWebviewRequestType)requestType {
    
    YYWebviewRequestType requestType = YYWebviewRequestTypeGet;
    if ([self.child respondsToSelector:@selector(webViewReqeustType)]) {
        
        requestType = [self.child webViewReqeustType];
    }
    return requestType;
}
- (NSURLRequest *)serializeRequestUrl:(NSString *)url methodName:(YYWebviewRequestType)methodName params:(NSDictionary *)params {
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:methodName==YYWebviewRequestTypeGet?@"GET":@"POST" URLString:url parameters:params error:nil];
    return request;
}

- (void)setCookies:(NSURLResponse *)response {
    
    NSHTTPURLResponse *rp = (NSHTTPURLResponse *)response;
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:rp.allHeaderFields forURL:rp.URL];
    for (NSHTTPCookie *cookie in cookies) {
        
        NSLog(@"cookie:%@",cookie);
    }
    NSString *cookieStr = [[rp allHeaderFields] valueForKey:@"Set-Cookie"];
    NSLog(@"%@",cookieStr);
}

//该方法主要是为了解决，WK 调用goBack方法后,返回页面的js代码不执行问题
- (void)reloadWebViewWhenNavigationBack:(WKNavigation *)navigation {
    //
    if ([self.webView.backNavigation isEqual:navigation]) {
        [self.webView reload];
        self.webView.backNavigation = nil;
    }
    
}

#pragma mark - target action
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        if (object == _webView) {
            
            [self.progress setAlpha:1.0f];
            [self.progress setProgress:self.webView.estimatedProgress animated:YES];
            if (self.webView.estimatedProgress >= 1.0f) {
                
                [UIView animateWithDuration:0.3 animations:^{
                   
                    [self.progress setAlpha:0.0f];
            
                } completion:^(BOOL finished) {
                 
                    self.progress.progress = 0;
                }];
            }
        } else {
            
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
        
        return;
    }
    
    if ([keyPath isEqualToString:@"title"]) {
        
        if (object == _webView) {
         
            self.navigationItem.title = self.webView.title;
        } else
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        
        return;
    }
    
    if ([keyPath isEqualToString:@"canGoBack"]) {
        
        if (object == _webView) {
            
            if (_webView.canGoBack) {
                
                [self webViewDidClick];
            }
        }
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
}
#pragma mark - getter and setter

- (WKWebView *)webView {
    
    if (!_webView) {
        _webView = [[CLWebView alloc] init];
        _webView.frame = self.view.bounds;
        _webView.navigationDelegate = self; // 导航代理
        _webView.UIDelegate = self;// 用户交互代理
        _webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    }
    return _webView;
}

- (NSMutableArray *)scriptArray {
    
    if (!_scriptArray) {
        
        _scriptArray = @[].mutableCopy;
    }
    return _scriptArray;
}

- (UIProgressView *)progress {
    
    if (!_progress) {
        
        _progress = [[UIProgressView alloc] init];
        //_progress.progressTintColor = [UIColor greenColor];
        [_progress setAlpha:0.0];
    }
    
    return _progress;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
