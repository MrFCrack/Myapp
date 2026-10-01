//
//  MFCDeviceIDHelper.h
//  Mr-FCrack
//

#import <Foundation/Foundation.h>

@interface MFCDeviceIDHelper : NSObject

// Device ID (hash SHA256 de todos los datos únicos)
+ (NSString *)deviceID;

// Versión corta del device ID (últimos 8 caracteres)
+ (NSString *)shortDeviceID;

// Modelo legible (ej: "iPhone 13 Pro")
+ (NSString *)deviceModelName;

// Identificador técnico del modelo (ej: "iPhone14,2")
+ (NSString *)deviceModelIdentifier;

// Versión de iOS (ej: "17.2")
+ (NSString *)systemVersion;

// Info completa del dispositivo (para enviar al servidor)
+ (NSDictionary *)deviceInfo;

@end
