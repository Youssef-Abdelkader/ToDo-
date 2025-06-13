#import "TodoTasksTableViewController.h"
#import "Task.h"
#import "UserDefault.h"
#import "AddTaskViewController.h"
#import "TaskDetailsViewController.h"

@interface TodoTasksTableViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property UserDefault* helper;
@property NSMutableArray<Task*>* allTodoTasks;
@property NSMutableArray<Task*>* filteredTasks;
@property NSMutableArray<Task*>* lowTasks;
@property NSMutableArray<Task*>* normalTasks;
@property NSMutableArray<Task*>* highTasks;
@property Task* selectedTask;
@property BOOL isSearching;

@end

@implementation TodoTasksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.helper = [[UserDefault alloc] init];
    self.allTodoTasks = [NSMutableArray new];
    self.filteredTasks = [NSMutableArray new];
    self.lowTasks = [NSMutableArray new];
    self.normalTasks = [NSMutableArray new];
    self.highTasks = [NSMutableArray new];
    self.isSearching = NO;
    
    self.allTodoTasks = [[self.helper getTasksByState:TaskStateTodo] mutableCopy];
    [self updatePriorityLists];
}

- (void)viewWillAppear:(BOOL)animated {
    [self syncData];
}

- (void)syncData {
    NSLog(@"data synced");
    [self getFreshData];
}

- (void)getFreshData {
    self.allTodoTasks = [[self.helper getTasksByState:TaskStateTodo] mutableCopy];
    [self updatePriorityLists];
    [self.tableView reloadData];
}

- (void)updatePriorityLists {
    NSArray* sourceArray = self.isSearching ? self.filteredTasks : self.allTodoTasks;
    self.lowTasks = [[self getListByPriority:TaskPriorityLow fromArray:sourceArray] mutableCopy];
    self.normalTasks = [[self getListByPriority:TaskPriorityNormal fromArray:sourceArray] mutableCopy];
    self.highTasks = [[self getListByPriority:TaskPriorityHigh fromArray:sourceArray] mutableCopy];
}

- (NSArray*)getListByPriority:(TaskPriority)priority fromArray:(NSArray<Task*>*)sourceArray {
    NSMutableArray* result = [NSMutableArray new];
    for (Task* currentTask in sourceArray) {
        if (currentTask.taskPriority == priority) {
            [result addObject:currentTask];
        }
    }
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"Low";
        case 1: return @"Normal";
        case 2: return @"High";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return self.lowTasks.count;
        case 1: return self.normalTasks.count;
        case 2: return self.highTasks.count;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskCell" forIndexPath:indexPath];
    
    Task* currentTask;
    switch (indexPath.section) {
        case 0: currentTask = [self.lowTasks objectAtIndex:indexPath.row]; break;
        case 1: currentTask = [self.normalTasks objectAtIndex:indexPath.row]; break;
        case 2: currentTask = [self.highTasks objectAtIndex:indexPath.row]; break;
        default: break;
    }
    
    UILabel* titleLabel = [cell viewWithTag:1];
    titleLabel.text = currentTask.taskTitle;
    
    UIImageView* taskImageView = [cell viewWithTag:2];
    taskImageView.image = [UIImage imageNamed:[self getImagePathWithPriority:currentTask.taskPriority]];
    
    return cell;
}

- (NSString*)getImagePathWithPriority:(TaskPriority)priority {
    switch (priority) {
        case TaskPriorityLow: return @"low";
        case TaskPriorityNormal: return @"normal";
        case TaskPriorityHigh: return @"high";
        default: return @"";
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Task* taskToDelete;
        switch (indexPath.section) {
            case 0:
                taskToDelete = [self.lowTasks objectAtIndex:indexPath.row];
                break;
            case 1:
                taskToDelete = [self.normalTasks objectAtIndex:indexPath.row];
                break;
            case 2:
                taskToDelete = [self.highTasks objectAtIndex:indexPath.row];
                break;
            default:
                return;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                    @"Delete Task"
message:@"Are you sure you want to delete this task?"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
            [self.helper deleteTask:taskToDelete];

            switch (indexPath.section) {
                case 0:
                    [self.lowTasks removeObject:taskToDelete];
                    break;
                case 1:
                    [self.normalTasks removeObject:taskToDelete];
                    break;
                case 2:
                    [self.highTasks removeObject:taskToDelete];
                    break;
            }

            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];

        [alert addAction:okAction];
        [alert addAction:cancelAction];

        [self presentViewController:alert animated:YES completion:nil];
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Task* selectedTask;
    switch (indexPath.section) {
        case 0: selectedTask = [self.lowTasks objectAtIndex:indexPath.row]; break;
        case 1: selectedTask = [self.normalTasks objectAtIndex:indexPath.row]; break;
        case 2: selectedTask = [self.highTasks objectAtIndex:indexPath.row]; break;
        default: break;
    }

    TaskDetailsViewController* taskDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detailsScreenId"];
    taskDetailsVC.currentTask = selectedTask;
    taskDetailsVC.syncDataDelegate = self;
    [self.navigationController pushViewController:taskDetailsVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.isSearching = NO;
        [self.filteredTasks removeAllObjects];
    } else {
        self.isSearching = YES;
        [self.filteredTasks removeAllObjects];
        for (Task* task in self.allTodoTasks) {
            if ([task.taskTitle.lowercaseString containsString:searchText.lowercaseString]) {
                [self.filteredTasks addObject:task];
            }
        }
    }
    [self updatePriorityLists];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    self.isSearching = NO;
    [self.filteredTasks removeAllObjects];
    [self updatePriorityLists];
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addTaskSegue"]) {
        AddTaskViewController* addTaskVC = [segue destinationViewController];
        addTaskVC.syncDataDelegate = self;
    }
}

@end
