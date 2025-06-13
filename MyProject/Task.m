
#import "Task.h"

@implementation Task

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.taskId = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    Task* other = (Task*) object;
    return [self.taskId isEqualToString:other.taskId];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self.taskId = [coder decodeObjectOfClass:[NSString class] forKey:@"taskId"];
    self.taskTitle = [coder decodeObjectOfClass:[NSString class] forKey:@"taskTitle"];
    self.taskDesc = [coder decodeObjectOfClass:[NSString class] forKey:@"taskDesc"];
    self.taskPriority = [coder decodeIntegerForKey:@"taskPriority"];
    self.taskState = [coder decodeIntegerForKey:@"taskState"];
    self.taskDate = [coder decodeObjectOfClass:[NSDate class] forKey:@"taskDate"];
    
    NSLog(@"initialzed from coder task %@", self.taskId);
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.taskId forKey:@"taskId"];
    [coder encodeObject:self.taskTitle forKey:@"taskTitle"];
    [coder encodeObject:self.taskDesc forKey:@"taskDesc"];
    [coder encodeInteger:self.taskPriority forKey:@"taskPriority"];
    [coder encodeInteger:self.taskState forKey:@"taskState"];
    [coder encodeObject:self.taskDate forKey:@"taskDate"];
    NSLog(@"encoded object with id %@ and title %@", self.taskId, self.taskTitle);
}


+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
