 

//  TodoTasksTableViewController.h
//  MyProject
//
//  Created by Abdo Allam  on 07/05/2025.
//
#import <UIKit/UIKit.h>
#import "SyncDataDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TodoTasksTableViewController : UITableViewController<SyncDataDelegate, UISearchBarDelegate>

@end

NS_ASSUME_NONNULL_END
