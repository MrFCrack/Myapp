//
//  MFCDeviceIDHelper.m
//  Mr-FCrack
//

#import "MFCDeviceIDHelper.h"
#import "MFCKeychainHelper.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>

@implementation MFCDeviceIDHelper

static NSString *const kMFCDeviceIDKey = @"mfc_device_id";
static NSString *const kMFCPersistentUUIDKey = @"mfc_persistent_uuid";

#pragma mark - Device ID

+ (NSString *)deviceID {
    // 1. Intentar leer del Keychain (persiste tras reinstalar)
    NSString *saved = [MFCKeychainHelper valueForKey:kMFCDeviceIDKey];
    if (saved && saved.length > 0) {
        return saved;
    }

    // 2. Generar uno nuevo
    NSString *newID = [self generateDeviceID];

    // 3. Guardarlo en el Keychain
    [MFCKeychainHelper saveValue:newID forKey:kMFCDeviceIDKey];

    return newID;
}

+ (NSString *)shortDeviceID {
    NSString *full = [self deviceID];
    if (full.length <= 8) return full;
    return [full substringFromIndex:full.length - 8];
}

#pragma mark - Generación

+ (NSString *)generateDeviceID {
    NSMutableString *raw = [NSMutableString string];

    // 1. UUID persistente (uno por instalación, guardado en Keychain)
    NSString *persistentUUID = [MFCKeychainHelper valueForKey:kMFCPersistentUUIDKey];
    if (!persistentUUID || persistentUUID.length == 0) {
        persistentUUID = [[NSUUID UUID] UUIDString];
        [MFCKeychainHelper saveValue:persistentUUID forKey:kMFCPersistentUUIDKey];
    }
    [raw appendString:persistentUUID];

    // 2. IDFV (Identifier For Vendor)
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (idfv) [raw appendString:idfv];

    // 3. Modelo técnico del dispositivo
    [raw appendString:[self deviceModelIdentifier]];

    // 4. Versión de iOS
    [raw appendString:[self systemVersion]];

    // 5. Nombre del sistema
    [raw appendString:[[UIDevice currentDevice] systemName]];

    // 6. Resolución de pantalla
    CGRect bounds = [UIScreen mainScreen].nativeBounds;
    [raw appendString:[NSString stringWithFormat:@"%.0fx%.0f",
                       bounds.size.width, bounds.size.height]];

    // 7. Hash SHA256 del conjunto
    return [self sha256:raw];
}

#pragma mark - Modelo del dispositivo

+ (NSString *)deviceModelIdentifier {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)deviceModelName {
    NSString *identifier = [self deviceModelIdentifier];

    // Mapeo de identificadores técnicos a nombres legibles
    static NSDictionary *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
            // iPhone 6s - 6s Plus
            @"iPhone8,1": @"iPhone 6s",
            @"iPhone8,2": @"iPhone 6s Plus",
            @"iPhone8,4": @"iPhone SE (1st)",

            // iPhone 7 - 7 Plus
            @"iPhone9,1": @"iPhone 7",
            @"iPhone9,3": @"iPhone 7",
            @"iPhone9,2": @"iPhone 7 Plus",
            @"iPhone9,4": @"iPhone 7 Plus",

            // iPhone 8 - 8 Plus - X
            @"iPhone10,1": @"iPhone 8",
            @"iPhone10,4": @"iPhone 8",
            @"iPhone10,2": @"iPhone 8 Plus",
            @"iPhone10,5": @"iPhone 8 Plus",
            @"iPhone10,3": @"iPhone X",
            @"iPhone10,6": @"iPhone X",

            // iPhone XR - XS - XS Max
            @"iPhone11,8": @"iPhone XR",
            @"iPhone11,2": @"iPhone XS",
            @"iPhone11,4": @"iPhone XS Max",
            @"iPhone11,6": @"iPhone XS Max",

            // iPhone 11 - 11 Pro - 11 Pro Max
            @"iPhone12,1": @"iPhone 11",
            @"iPhone12,3": @"iPhone 11 Pro",
            @"iPhone12,5": @"iPhone 11 Pro Max",

            // iPhone SE (2nd, 3rd)
            @"iPhone12,8": @"iPhone SE (2nd)",

            // iPhone 12 - 12 mini - 12 Pro - 12 Pro Max
            @"iPhone13,1": @"iPhone 12 mini",
            @"iPhone13,2": @"iPhone 12",
            @"iPhone13,3": @"iPhone 12 Pro",
            @"iPhone13,4": @"iPhone 12 Pro Max",

            // iPhone 13 - 13 mini - 13 Pro - 13 Pro Max
            @"iPhone14,4": @"iPhone 13 mini",
            @"iPhone14,5": @"iPhone 13",
            @"iPhone14,2": @"iPhone 13 Pro",
            @"iPhone14,3": @"iPhone 13 Pro Max",

            // iPhone SE (3rd)
            @"iPhone14,6": @"iPhone SE (3rd)",

            // iPhone 14 - 14 Plus - 14 Pro - 14 Pro Max
            @"iPhone14,7": @"iPhone 14",
            @"iPhone14,8": @"iPhone 14 Plus",
            @"iPhone15,2": @"iPhone 14 Pro",
            @"iPhone15,3": @"iPhone 14 Pro Max",

            // iPhone 15 - 15 Plus - 15 Pro - 15 Pro Max
            @"iPhone15,4": @"iPhone 15",
            @"iPhone15,5": @"iPhone 15 Plus",
            @"iPhone16,1": @"iPhone 15 Pro",
            @"iPhone16,2": @"iPhone 15 Pro Max",

            // iPhone 16
            @"iPhone17,1": @"iPhone 16 Pro",
            @"iPhone17,2": @"iPhone 16 Pro Max",
            @"iPhone17,3": @"iPhone 16",
            @"iPhone17,4": @"iPhone 16 Plus",
            @"iPhone17,5": @"iPhone 16e",

            // iPad (algunos ejemplos)
            @"iPad14,1": @"iPad mini (6th)",
            @"iPad14,2": @"iPad mini (6th)",
        };
    });

    NSString *name = map[identifier];
    if (name) return name;

    // Si no está en el mapa, devolver el identificador técnico
    return identifier;
}

#pragma mark - Sistema

+ (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

#pragma mark - Info completa

+ (NSDictionary *)deviceInfo {
    NSString *deviceID = [self deviceID];
    CGRect bounds = [UIScreen mainScreen].nativeBounds;

    return @{
        @"device_id": deviceID,
        @"short_id": [self shortDeviceID],
        @"model": [self deviceModelName],
        @"model_id": [self deviceModelIdentifier],
        @"system": [self systemVersion],
        @"system_name": [[UIDevice currentDevice] systemName],
        @"screen": [NSString stringWithFormat:@"%.0fx%.0f", bounds.size.width, bounds.size.height],
        @"idfv": [[[UIDevice currentDevice] identifierForVendor] UUIDString] ?: @"",
        @"name": [[UIDevice currentDevice] name] ?: @""
    };
}

#pragma mark - SHA256

+ (NSString *)sha256:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cStr, (CC_LONG)strlen(cStr), digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end
