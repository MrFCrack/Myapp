//
//  MFCKeychainHelper.m
//  Mr-FCrack
//

#import "MFCKeychainHelper.h"
#import <Security/Security.h>

@implementation MFCKeychainHelper

// Service: identificador único de tu app en el Keychain
static NSString *const kMFCService = @"com.mrfcrack.app";

#pragma mark - Guardar

+ (BOOL)saveValue:(NSString *)value forKey:(NSString *)key {
    if (!value || !key) return NO;

    // 1. Borrar el valor anterior si existe (para no duplicar)
    [self deleteValueForKey:key];

    // 2. Preparar el diccionario de datos
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *query = @{
        (__bridge id)kSecClass:       (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kMFCService,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecValueData:   data,
        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlock
    };

    // 3. Añadir al Keychain
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    return status == errSecSuccess;
}

#pragma mark - Leer

+ (NSString *)valueForKey:(NSString *)key {
    if (!key) return nil;

    NSDictionary *query = @{
        (__bridge id)kSecClass:       (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kMFCService,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecReturnData:  @YES,
        (__bridge id)kSecMatchLimit:  (__bridge id)kSecMatchLimitOne
    };

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

    if (status != errSecSuccess || !result) return nil;

    NSData *data = (__bridge_transfer NSData *)result;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - Borrar uno

+ (BOOL)deleteValueForKey:(NSString *)key {
    if (!key) return NO;

    NSDictionary *query = @{
        (__bridge id)kSecClass:       (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kMFCService,
        (__bridge id)kSecAttrAccount: key
    };

    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    return status == errSecSuccess || status == errSecItemNotFound;
}

#pragma mark - Borrar todo

+ (BOOL)deleteAll {
    NSDictionary *query = @{
        (__bridge id)kSecClass:       (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kMFCService
    };

    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    return status == errSecSuccess || status == errSecItemNotFound;
}

@end
