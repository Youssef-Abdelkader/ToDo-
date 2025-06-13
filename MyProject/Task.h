#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, TaskState) {
    TaskStateTodo = 0,
    TaskStateInProgress = 1,
    TaskStateDone = 2
};

typedef NS_ENUM(NSInteger, TaskPriority) {
    TaskPriorityLow = 0,
    TaskPriorityNormal = 1,
    TaskPriorityHigh = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface Task : NSObject<NSSecureCoding>

@property NSString* taskId;
@property NSString* taskTitle;
@property NSString* taskDesc;
@property TaskPriority taskPriority;
@property TaskState taskState;
@property NSDate* taskDate;


@end

NS_ASSUME_NONNULL_END
