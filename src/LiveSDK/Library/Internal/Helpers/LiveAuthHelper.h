//
//  LiveAuthHelper.h
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

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <Foundation/Foundation.h>

#import "LiveConnectSession.h"

@interface LiveAuthHelper : NSObject

+ (NSBundle *) getSDKBundle;

+ (NSArray *) normalizeScopes:(NSArray *)scopes;

+ (BOOL) isScopes:(NSArray *)scopes1
         subSetOf:(NSArray *)scopes2;

+ (NSURL *) buildAuthUrlWithClientId:(NSString *)clientId
                         redirectUri:(NSString *)redirectUri
                              scopes:(NSArray *)scopes;

+ (NSData *) buildGetTokenBodyDataWithClientId:(NSString *)clientId
                                   redirectUri:(NSString *)redirectUri
                                      authCode:(NSString *)authCode;

+ (NSData *) buildRefreshTokenBodyDataWithClientId:(NSString *)clientId
                                      refreshToken:(NSString *)refreshToken
                                             scope:(NSArray *)scopes;

+ (void) clearAuthCookie;

+ (void) copyFromSharedCookiesToWebKitCookieStore:(WKHTTPCookieStore *)webKitCookieStore;

+ (void) copyToSharedCookiesFromWebKitCookieStore:(WKHTTPCookieStore *)webKitCookieStore;

+ (NSError *) createAuthError:(NSInteger)code
                         info:(NSDictionary *)info;

+ (NSError *) createAuthError:(NSInteger)code
                     errorStr:(NSString *)errorStr
                  description:(NSString *)description
                   innerError:(NSError *)innerError;

+ (NSURL *) getRetrieveTokenUrl;

+ (NSString *) getDefaultRedirectUrlString;

+ (BOOL) isiPad;

+ (id) readAuthResponse:(NSData *)data;

+ (BOOL) isSessionValid:(LiveConnectSession *)session;

+ (BOOL) shouldRefreshToken:(LiveConnectSession *)session
               refreshToken:(NSString *)refreshToken;

+ (void) overrideLoginServer:(NSString *)loginServer
                   apiServer:(NSString *)apiServer;

@end
