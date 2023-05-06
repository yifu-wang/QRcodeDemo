//
//  QRCodeResultViewController.m
//  QRCodeDemo
//
//  Created by didi on 2023/5/5.
//

#import "QRCodeResultViewController.h"
#import "ZWScanViewController.h"
#import <WebKit/WebKit.h>
@interface QRCodeResultViewController ()

@end

@implementation QRCodeResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSLog(@"%@1111",_resultString);
    WKWebView *web = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_resultString]];
    [self.view addSubview:web];
    [web loadRequest:request];
    //[self.view addSubview:_resultLabel];

}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
   if(navigationAction.targetFrame ==nil) {
    [webView loadRequest:navigationAction.request];

    }
    decisionHandler( WKNavigationActionPolicyAllow );
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
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
