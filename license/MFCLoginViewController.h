//
//  MFCLoginViewController.h
//  Mr-FCrack
//

#import <UIKit/UIKit.h>

@interface MFCLoginViewController : UIViewController

// Se llama cuando la key es válida y el login ha sido exitoso
@property (nonatomic, copy) void (^onSuccess)(void);

@end
