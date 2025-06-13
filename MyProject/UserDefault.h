
#import <Foundation/Foundation.h>
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserDefault : NSObject

@property NSUserDefaults* df;

-(NSArray<Task*> *) getAllTasks;
-(NSArray<Task*> *) getTasksByState: (TaskState) state;
-(NSArray<Task*> *) getTasksByPriority: (TaskPriority) priority;

-(NSArray<Task*> *) searchTasksByTitle: (NSString*) title;

-(void) addTask: (Task*) task;
-(void) updateTask: (Task*) task;
-(void) deleteTask: (Task*) task;

@end

NS_ASSUME_NONNULL_END
