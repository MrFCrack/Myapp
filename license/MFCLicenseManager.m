//
//  MFCLicenseManager.m
//  Mr-FCrack
//

#import "MFCLicenseManager.h"
#import "MFCKeychainHelper.h"

// Claves del Keychain
static NSString *const kMFCKeyUserKey  = @"mfc_user_key";
static NSString *const kMFCKeyUsername = @"mfc_username";
static NSString *const kMFCKeyPlan     = @"mfc_plan";

@implementation MFCLicenseManager

#pragma mark - Singleton

+ (instancetype)shared {
    static MFCLicenseManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MFCLicenseManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadFromKeychain];
    }
    return self;
}

#pragma mark - Estado

- (BOOL)hasKey {
    NSString *key = [self currentKey];
    return key && key.length > 0;
}

- (NSString *)currentKey {
    return [MFCKeychainHelper valueForKey:kMFCKeyUserKey];
}

- (NSString *)username {
    return [MFCKeychainHelper valueForKey:kMFCKeyUsername];
}

- (NSString *)plan {
    return [MFCKeychainHelper valueForKey:kMFCKeyPlan];
}

#pragma mark - Guardar

- (void)saveKey:(NSString *)key {
    if (!key || key.length == 0) return;
    [MFCKeychainHelper saveValue:key forKey:kMFCKeyUserKey];
    NSLog(@"[LicenseManager] key guardada: %@...", [key substringToIndex:MIN(8, key.length)]);
}

- (void)saveUsername:(NSString *)username {
    if (!username) return;
    [MFCKeychainHelper saveValue:username forKey:kMFCKeyUsername];
}

- (void)savePlan:(NSString *)plan {
    if (!plan) return;
    [MFCKeychainHelper saveValue:plan forKey:kMFCKeyPlan];
}

#pragma mark - Logout

- (void)logout {
    [MFCKeychainHelper deleteValueForKey:kMFCKeyUserKey];
    [MFCKeychainHelper deleteValueForKey:kMFCKeyUsername];
    [MFCKeychainHelper deleteValueForKey:kMFCKeyPlan];
    NSLog(@"[LicenseManager] sesión cerrada");
}

#pragma mark - Carga

- (void)loadFromKeychain {
    NSString *key = [MFCKeychainHelper valueForKey:kMFCKeyUserKey];
    if (key && key.length > 0) {
        NSLog(@"[LicenseManager] key cargada del Keychain: %@...", [key substringToIndex:MIN(8, key.length)]);
    } else {
        NSLog(@"[LicenseManager] no hay key guardada");
    }
}

@end
