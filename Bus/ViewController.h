//
//  ViewController.h
//  Bus
//
//  Created by panda zheng on 13-4-22.
//  Copyright (c) 2013年 panda zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,
                    UISearchBarDelegate,UISearchDisplayDelegate>
{
    UITableView *busLineTableView;
    NSMutableArray *filteredListContent;
//    NSArray *recipes;
}

@property (nonatomic, retain) IBOutlet UITableView *busLineTableView;
@property (nonatomic, retain) NSMutableArray *filteredListContent;

@end
