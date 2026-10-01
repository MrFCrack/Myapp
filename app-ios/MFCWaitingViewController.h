//
//  MFCWaitingViewController.h
//  Mr-FCrack
//

#import <UIKit/UIKit.h>

@interface MFCWaitingViewController : UIViewController

// Callback cuando encuentra Free Fire MAX
@property (nonatomic, copy) void (^onGameFound)(void);

@end
