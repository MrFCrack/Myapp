//
//  MFCMessageHandler.h
//  Mr-FCrack
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface MFCMessageHandler : NSObject <WKScriptMessageHandler>

// Registrar el handler en un WKWebView
+ (void)registerInWebView:(WKWebView *)webView;

// Enviar datos al HTML (llama a window.MFC...)
+ (void)sendToWebView:(WKWebView *)webView
               action:(NSString *)action
                 data:(NSDictionary *)data;

@end
