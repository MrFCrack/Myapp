//
//  AppDelegate.m
//  Mr-FCrack
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MFCWaitingViewController.h"
#import "../license/MFCLicenseManager.h"
#import "../license/MFCLoginViewController.h"

// Variable global de Tweak.mm
extern bool gMFCLoginCompleted;

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] init];
    self.window.backgroundColor = [UIColor blackColor];

    // Comprobar si hay key guardada
    [[MFCLicenseManager shared] loadFromKeychain];

    if ([[MFCLicenseManager shared] hasKey]) {
        NSLog(@"[AppDelegate] key encontrada. Arrancando...");
        [self showWaitingScreen];
    } else {
        NSLog(@"[AppDelegate] sin key. Mostrando login...");
        [self showLogin];
    }

    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Pantallas

- (void)showLogin {
    MFCLoginViewController *login = [[MFCLoginViewController alloc] init];

    __weak typeof(self) weakSelf = self;
    login.onSuccess = ^{
        NSLog(@"[AppDelegate] login OK. Mostrando pantalla de espera...");
        [weakSelf showWaitingScreen];
    };

    self.window.rootViewController = login;
}

- (void)showWaitingScreen {
    MFCWaitingViewController *waiting = [[MFCWaitingViewController alloc] init];

    __weak typeof(self) weakSelf = self;
    waiting.onGameFound = ^{
        NSLog(@"[AppDelegate] Free Fire MAX encontrado. Arrancando app...");
        [weakSelf showMainApp];
    };

    self.window.rootViewController = waiting;
}

- (void)showMainApp {
    // Marcar el login como completado para que Tweak.mm cree el FloatMenu
    gMFCLoginCompleted = true;

    ViewController *vc = [[ViewController alloc] init];
    self.window.rootViewController = vc;
}

#pragma mark - Ciclo de vida

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
