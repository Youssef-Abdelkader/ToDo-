//الحقونا
#import "InProgressTasksTableViewController.h"
#import "Task.h"
#import "UserDefault.h"
#import "AddTaskViewController.h"
#import "TaskDetailsViewController.h"


@interface InProgressTasksTableViewController ()

@property UserDefault* helper;
@property NSMutableArray<Task*>* allTodoTasks;
@property NSMutableArray<Task*>* lowTasks;
@property NSMutableArray<Task*>* normalTasks;
@property NSMutableArray<Task*>* highTasks;
@property Task* selectedTask;
@property BOOL isFiltering;

@end

@implementation InProgressTasksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.helper = [[UserDefault alloc] init];
    self.allTodoTasks = [NSMutableArray new];
    self.lowTasks = [NSMutableArray new];
    self.normalTasks = [NSMutableArray new];
    self.highTasks = [NSMutableArray new];
    self.isFiltering = NO;
    
    self.allTodoTasks = [[self.helper getTasksByState:TaskStateInProgress] mutableCopy];
    self.lowTasks = [[self getListByPriority:TaskPriorityLow] mutableCopy];
    self.normalTasks = [[self getListByPriority:TaskPriorityNormal] mutableCopy];
    self.highTasks = [[self getListByPriority:TaskPriorityHigh] mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated {
    [self syncData];
}

- (IBAction)filter:(UIBarButtonItem *)sender {
    self.isFiltering = !self.isFiltering;
    [self.tableView reloadData];
}

-(NSArray*) getListByPriority:(TaskPriority) priority {
    NSMutableArray* result = [NSMutableArray new];
    
    for(int i = 0 ; i < self.allTodoTasks.count ; i++) {
        Task* currentTask = [self.allTodoTasks objectAtIndex:i];
        if(currentTask.taskPriority == priority) {
            [result addObject:currentTask];
        }
    }
    
    return result;
}

-(void) getFreshData {
    self.allTodoTasks = [[self.helper getTasksByState:TaskStateInProgress] mutableCopy];
    self.lowTasks = [[self getListByPriority:TaskPriorityLow] mutableCopy];
    self.normalTasks = [[self getListByPriority:TaskPriorityNormal] mutableCopy];
    self.highTasks = [[self getListByPriority:TaskPriorityHigh] mutableCopy];
    [self.tableView reloadData];
}

- (void)syncData {
    NSLog(@"data synced");
    [self getFreshData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isFiltering ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(self.isFiltering) {
        switch (section) {
            case 0:
                return self.lowTasks.count;
                break;
                
            case 1:
                return self.normalTasks.count;
                break;
                
            case 2:
                return self.highTasks.count;
                break;
                
            default:
                return [self getListByPriority:TaskPriorityLow].count;
                break;
        }
    }else {
        return self.allTodoTasks.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.isFiltering) {
        switch (section) {
            case 0:
                return @"Low";
                break;
                
            case 1:
                return @"Normal";
                break;
                
            case 2:
                return @"High";
                break;

            default:
                return @"NONE";
                break;
        }
    } else {
        return @"";
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskCell" forIndexPath:indexPath];
    
    Task* currentTask;
    if(self.isFiltering) {
        switch (indexPath.section) {
            case 0:
                currentTask = [self.lowTasks objectAtIndex:indexPath.row];
                break;
                
            case 1:
                currentTask = [self.normalTasks objectAtIndex:indexPath.row];
                break;
                
            case 2:
                currentTask = [self.highTasks objectAtIndex:indexPath.row];
                break;
                
            default:
                break;
        }
    } else {
        currentTask = [self.allTodoTasks objectAtIndex:indexPath.row];
    }
    
    
    // Configure the cell...
    UILabel* titleLabel = [cell viewWithTag:1];
    titleLabel.text = currentTask.taskTitle;
    
    UIImageView* taskImageview = [cell viewWithTag:2];
    NSString* imagePath = [self getImagePathWithPriority: currentTask.taskPriority];
    taskImageview.image = [UIImage imageNamed: imagePath];
    

    
    return cell;
}

-(NSString*) getImagePathWithPriority: (TaskPriority) priority {
    switch (priority) {
        case TaskPriorityLow:
            return @"low";
            break;
            
        case TaskPriorityNormal:
            return @"normal";
            break;
            
        case TaskPriorityHigh:
            return @"high";
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete Task"
                                                                       message:@"Are you sure you want to delete this task?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * action) {
            Task* selectedTask;
            
            if (self.isFiltering) {
                switch (indexPath.section) {
                    case 0:
                        selectedTask = self.lowTasks[indexPath.row];
                        [self.lowTasks removeObject:selectedTask];
                        break;
                    case 1:
                        selectedTask = self.normalTasks[indexPath.row];
                        [self.normalTasks removeObject:selectedTask];
                        break;
                    case 2:
                        selectedTask = self.highTasks[indexPath.row];
                        [self.highTasks removeObject:selectedTask];
                        break;
                    default:
                        break;
                }
            } else {
                selectedTask = self.allTodoTasks[indexPath.row];
                [self.allTodoTasks removeObject:selectedTask];
            }
            
            [self.helper deleteTask:selectedTask];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:yesAction];
        [alert addAction:noAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Task* selectedTask;
    
    if(self.isFiltering) {
        switch (indexPath.section) {
            case 0:
                selectedTask = [self.lowTasks objectAtIndex:indexPath.row];
                break;
                
            case 1:
                selectedTask = [self.normalTasks objectAtIndex:indexPath.row];
                break;
                
            case 2:
                selectedTask = [self.highTasks objectAtIndex:indexPath.row];
                break;
                
            default:
                break;
        }
    } else {
        selectedTask = [self.allTodoTasks objectAtIndex:indexPath.row];
    }
    
    
    TaskDetailsViewController* taskDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detailsScreenId"];
    taskDetailsVC.currentTask = selectedTask;
    taskDetailsVC.syncDataDelegate = self;
    [self.navigationController pushViewController:taskDetailsVC animated:YES];
    
}

@end
