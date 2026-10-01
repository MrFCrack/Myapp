//
//  MFCLicenseManager.h
//  Mr-FCrack
//

#import <Foundation/Foundation.h>

@interface MFCLicenseManager : NSObject

+ (instancetype)shared;

// Estado
- (BOOL)hasKey;              // ¿Hay alguna key guardada?
- (NSString *)currentKey;    // Devuelve la key guardada (o nil)
- (NSString *)username;      // Devuelve el nombre de usuario (o nil)
- (NSString *)plan;          // Devuelve el plan (o nil)

// Acciones
- (void)saveKey:(NSString *)key;
- (void)saveUsername:(NSString *)username;
- (void)savePlan:(NSString *)plan;
- (void)logout;              // Borra la key y toda la info

// Carga inicial
- (void)loadFromKeychain;    // Lee todo del Keychain al arrancar

@end
