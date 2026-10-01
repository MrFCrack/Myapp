//
//  MFCKeychainHelper.h
//  Mr-FCrack
//

#import <Foundation/Foundation.h>

@interface MFCKeychainHelper : NSObject

+ (BOOL)saveValue:(NSString *)value forKey:(NSString *)key;
+ (NSString *)valueForKey:(NSString *)key;
+ (BOOL)deleteValueForKey:(NSString *)key;
+ (BOOL)deleteAll;

@end
