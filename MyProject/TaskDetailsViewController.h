
#import <UIKit/UIKit.h>
#import "Task.h"
#import "SyncDataDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaskDetailsViewController : UIViewController

@property Task* currentTask;
@property id<SyncDataDelegate> syncDataDelegate;

@end

NS_ASSUME_NONNULL_END
