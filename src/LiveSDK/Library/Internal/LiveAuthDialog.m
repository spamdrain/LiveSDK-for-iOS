//
//  LiveAuthDialog.m
//  Live SDK for iOS
//
//  Copyright 2015 Microsoft Corporation
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import "LiveAuthDialog.h"
#import "LiveAuthHelper.h"

@implementation LiveAuthDialog

@synthesize webView, canDismiss, delegate = _delegate;

- (id)initWithStartUrl:(NSURL *)startUrl
                endUrl:(NSString *)endUrl
              delegate:(id<LiveAuthDialogDelegate>)delegate
{
    self = [super init];

    if (self)
    {
        _startUrl = [startUrl retain];
        _endUrl =  [endUrl retain];
        _delegate = delegate;
        canDismiss = NO;
    }
    
    return self;
}

- (void)dealloc 
{
    [_startUrl release];
    [_endUrl release];
    [webView release];
    
    [super dealloc];
}

- (void)loadView
{
    WKWebViewConfiguration *webViewConfiguration = [[[WKWebViewConfiguration alloc] init] autorelease];
    webViewConfiguration.websiteDataStore = [[WKWebsiteDataStore nonPersistentDataStore] autorelease];
    [LiveAuthHelper copyFromSharedCookiesToWebKitCookieStore:webViewConfiguration.websiteDataStore.httpCookieStore];

    self.view = [[UIView alloc] init];
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfiguration];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.webView];
    [self.webView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [self.webView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    [self.webView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
    [self.webView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.navigationDelegate = self;
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                              target:self
                                              action:@selector(dismissView:)] autorelease];
    
    //Load the Url request in the UIWebView.
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:_startUrl];
    [webView loadRequest:requestObj];    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // We can't dismiss this modal dialog before it appears.
    canDismiss = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Copy cookies set by the web view to the shared NSHTTPCookieStorage so that they can be
    // retrieved and cleared later on in LiveAuthHelper::clearAuthCookie when logging out.
    [LiveAuthHelper copyToSharedCookiesFromWebKitCookieStore:webView.configuration.websiteDataStore.httpCookieStore];

    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_delegate authDialogDisappeared];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // This mehtod is supported in iOS 5. On iOS 6, this method is replaced with
    // (BOOL)shouldAutorotate and (NSUInteger)supportedInterfaceOrientations
    // We don't implement the iOS 6 rotating methods because we choose the default behavior.
    // The behavior specified here for iOS 5 is consistent with iOS6 default behavior. 
    // iPad: Rotate to any orientation
    // iPhone: Rotate to any orientation except for portrait upside down.
    return ([LiveAuthHelper isiPad] || (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown));
}

// User clicked the "Cancel" button.
- (void) dismissView:(id)sender 
{
    [_delegate authDialogCanceled];
}

#pragma mark WKNavigationDelegate methods

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = [navigationAction.request URL];

    if ([[url absoluteString] hasPrefix: _endUrl])
    {
        [_delegate authDialogCompletedWithResponse:url];
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    // Ignore the error triggered by page reload
    if ([error.domain isEqualToString:@"NSURLErrorDomain"] && error.code == -999)
        return;
    
    // Ignore the error triggered by disposing the view.
    if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)
        return;
    
    [_delegate authDialogFailedWithError:error];
}

@end
