//
//  MFCMessageHandler.m
//  Mr-FCrack
//

#import "MFCMessageHandler.h"
#import "../mods/MFCModManager.h"
#import "../mods/MFCModFormat.h"
#import "../license/MFCLicenseManager.h"

// Nombre del handler en el WebView (debe coincidir con el JS)
static NSString *const kMFCHandlerName = @"mfc";

// Referencia débil al WebView actual (para enviar respuestas)
static __weak WKWebView *gCurrentWebView = nil;

@implementation MFCMessageHandler

#pragma mark - Registro

+ (void)registerInWebView:(WKWebView *)webView {
    if (!webView) return;

    gCurrentWebView = webView;

    WKUserContentController *ucc = webView.configuration.userContentController;
    [ucc addScriptMessageHandler:[[MFCMessageHandler alloc] init] name:kMFCHandlerName];

    NSLog(@"[MessageHandler] registrado en el WebView");
}

#pragma mark - Envío al HTML

+ (void)sendToWebView:(WKWebView *)webView
               action:(NSString *)action
                 data:(NSDictionary *)data {
    if (!webView || !action) return;

    // Serializar a JSON
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"action"] = action;
    payload[@"data"] = data ?: @{};

    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&err];
    if (err || !jsonData) {
        NSLog(@"[MessageHandler] error serializando: %@", err);
        return;
    }

    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    // Llamar a window.MFCReceiveFromNative(json)
    NSString *js = [NSString stringWithFormat:@"window.MFCReceiveFromNative && window.MFCReceiveFromNative(%@);", jsonStr];

    dispatch_async(dispatch_get_main_queue(), ^{
        [webView evaluateJavaScript:js completionHandler:nil];
    });
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {

    if (![message.name isEqualToString:kMFCHandlerName]) return;

    NSDictionary *body = message.body;
    if (![body isKindOfClass:[NSDictionary class]]) return;

    NSString *action = body[@"action"];
    NSDictionary *data = body[@"data"] ?: @{};

    NSLog(@"[MessageHandler] ← %@", action);

    [self handleAction:action data:data];
}

#pragma mark - Router de acciones

- (void)handleAction:(NSString *)action data:(NSDictionary *)data {
    if ([action isEqualToString:@"requestModsList"]) {
        [self handleRequestModsList];
    } else if ([action isEqualToString:@"toggleMod"]) {
        [self handleToggleMod:data];
    } else if ([action isEqualToString:@"setModValue"]) {
        [self handleSetModValue:data];
    } else if ([action isEqualToString:@"syncMods"]) {
        [self handleSyncMods];
    } else if ([action isEqualToString:@"requestAccountInfo"]) {
        [self handleRequestAccountInfo];
    } else if ([action isEqualToString:@"windowDidOpen"]) {
        NSLog(@"[MessageHandler] ventana abierta");
    } else if ([action isEqualToString:@"windowDidClose"]) {
        NSLog(@"[MessageHandler] ventana cerrada");
    } else if ([action isEqualToString:@"iconDidMove"]) {
        [self handleIconDidMove:data];
    } else if ([action isEqualToString:@"iconDidEnterMoveMode"]) {
        NSLog(@"[MessageHandler] icono modo mover");
    } else if ([action isEqualToString:@"iconDidExitMoveMode"]) {
        NSLog(@"[MessageHandler] icono modo normal");
    } else {
        NSLog(@"[MessageHandler] acción desconocida: %@", action);
    }
}

#pragma mark - Handlers específicos

- (void)handleRequestModsList {
    NSArray<MFCModFormat *> *mods = [[MFCModManager shared] installedMods];

    NSMutableArray *modsArr = [NSMutableArray array];
    for (MFCModFormat *mod in mods) {
        [modsArr addObject:@{
            @"id": mod.modID ?: @"",
            @"name": mod.name ?: @"",
            @"description": mod.desc ?: @"",
            @"version": mod.version ?: @"1.0",
            @"uiMode": [self uiModeString:mod.uiMode],
            @"isEnabled": @(mod.isEnabled),
            @"currentValue": mod.currentValue ?: @"0"
        }];
    }

    [self sendBack:@"modsLoaded" data:@{@"mods": modsArr}];
}

- (void)handleToggleMod:(NSDictionary *)data {
    NSString *modId = data[@"modId"];
    BOOL enabled = [data[@"enabled"] boolValue];

    if (!modId) return;

    MFCModFormat *mod = [[MFCModManager shared] modWithID:modId];
    if (!mod) return;

    BOOL ok = [[MFCModManager shared] toggleMod:mod enabled:enabled];

    [self sendBack:@"modStateChanged" data:@{
        @"modId": modId,
        @"enabled": @(enabled),
        @"ok": @(ok)
    }];
}

- (void)handleSetModValue:(NSDictionary *)data {
    NSString *modId = data[@"modId"];
    NSString *value = data[@"value"];

    if (!modId || !value) return;

    MFCModFormat *mod = [[MFCModManager shared] modWithID:modId];
    if (!mod) return;

    BOOL ok = [[MFCModManager shared] updateModValue:mod value:value];

    [self sendBack:@"modValueUpdated" data:@{
        @"modId": modId,
        @"value": value,
        @"ok": @(ok)
    }];
}

- (void)handleSyncMods {
    [[MFCModManager shared] syncWithBackendWithCompletion:^(BOOL ok, NSError *error) {
        [self sendBack:@"syncComplete" data:@{
            @"ok": @(ok),
            @"error": error.localizedDescription ?: @""
        }];
    }];
}

- (void)handleRequestAccountInfo {
    MFCLicenseManager *lm = [MFCLicenseManager shared];

    NSString *key = [lm currentKey] ?: @"----";
    NSDate *expires = [lm expirationDate];

    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"dd/MM/yyyy";
    NSString *expiresStr = expires ? [fmt stringFromDate:expires] : @"--/--/----";

    [self sendBack:@"accountInfo" data:@{
        @"key": key,
        @"expires": expiresStr,
        @"valid": @([lm hasValidLicense])
    }];
}

- (void)handleIconDidMove:(NSDictionary *)data {
    // Guardar la posición del icono
    NSNumber *x = data[@"x"];
    NSNumber *y = data[@"y"];

    if (x && y) {
        [[NSUserDefaults standardUserDefaults] setObject:x forKey:@"mfc_icon_x"];
        [[NSUserDefaults standardUserDefaults] setObject:y forKey:@"mfc_icon_y"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"[MessageHandler] posición del icono guardada: (%@, %@)", x, y);
    }
}

#pragma mark - Helpers

- (void)sendBack:(NSString *)action data:(NSDictionary *)data {
    if (gCurrentWebView) {
        [MFCMessageHandler sendToWebView:gCurrentWebView action:action data:data];
    }
}

- (NSString *)uiModeString:(MFCModUIMode)mode {
    switch (mode) {
        case MFCModUIModeInput:  return @"input";
        case MFCModUIModeSwitch: return @"switch";
        case MFCModUIModeSlider: return @"slider";
        default: return @"switch";
    }
}

@end
