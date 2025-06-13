

#import "UserDefault.h"

@implementation UserDefault

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.df = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (NSArray<Task *> *)getAllTasks {
    NSData* data = [self.df objectForKey:@"tasks"];
    if(data) {
        NSSet* classes = [NSSet setWithObjects:[NSArray class], [Task class], nil];
        NSArray* tasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:nil];
        
        NSLog(@"you have %lu tasks", tasks.count);
        
        return tasks;
    } else {
        NSLog(@"tasks are emptyyy");
        return @[];
    }
}

- (NSArray<Task *> *)getTasksByPriority:(TaskPriority)priority {
    NSMutableArray* allTasks = [[self getAllTasks] mutableCopy];
    NSMutableArray* result = [NSMutableArray new];
    
    for(int i = 0 ; i < allTasks.count ; i++) {
        Task* currentTask = [allTasks objectAtIndex:i];
        if(currentTask.taskPriority == priority) {
            [result addObject:currentTask];
        }
    }
    
    NSLog(@"result for priority %lu = %lu tasks", priority, result.count);
    
    return result;
}

- (NSArray<Task *> *)getTasksByState:(TaskState)state {
    NSMutableArray* allTasks = [[self getAllTasks] mutableCopy];
    NSMutableArray* result = [NSMutableArray new];
    
    for(int i = 0 ; i < allTasks.count ; i++) {
        Task* currentTask = [allTasks objectAtIndex:i];
        if(currentTask.taskState == state) {
            [result addObject:currentTask];
        }
    }
    
    NSLog(@"result for state %lu = %lu tasks", state, result.count);
    
    return result;
}

- (void)addTask:(Task *)task {
    
    NSMutableArray* tasks = [[self getAllTasks] mutableCopy];
    [tasks addObject:task];
    
    NSData* encodedTasks = [NSKeyedArchiver archivedDataWithRootObject:tasks requiringSecureCoding:YES error:nil];
    [self.df setObject:encodedTasks forKey:@"tasks"];
    
    NSLog(@"added task successfully with id: %@", task.taskId);
    
}

- (void)updateTask:(Task *)task {
    NSMutableArray* tasks = [[self getAllTasks] mutableCopy];
    NSInteger taskIndex = [tasks indexOfObject:task];
    tasks[taskIndex] = task;
    
    NSData* encodedTasks = [NSKeyedArchiver archivedDataWithRootObject:tasks requiringSecureCoding:YES error:nil];
    [self.df setObject:encodedTasks forKey:@"tasks"];
    
    NSLog(@"updated task successfully with id: %@", task.taskId);
}

- (void)deleteTask:(Task *)task {
    NSMutableArray* tasks = [[self getAllTasks] mutableCopy];
    [tasks removeObject:task];
    
    NSData* encodedTasks = [NSKeyedArchiver archivedDataWithRootObject:tasks requiringSecureCoding:YES error:nil];
    [self.df setObject:encodedTasks forKey:@"tasks"];
    
    NSLog(@"deleted task successfully with id: %@", task.taskId);
}

- (NSArray<Task *> *)searchTasksByTitle:(NSString *)title {
    
    if(title.length == 0) {
        return [self getTasksByState:TaskStateTodo];
    }
    
    NSMutableArray* results = [NSMutableArray new];
    NSArray* allTasks = [self getTasksByState:TaskStateTodo];
    
    for(int i  = 0 ; i < allTasks.count ; i++) {
        Task* currentTask = [allTasks objectAtIndex:i];
        
        ;
        
        if([[currentTask.taskTitle lowercaseString] containsString:[title lowercaseString]]) {
            [results addObject:currentTask];
        }
    }
    
    return results;
}



@end
