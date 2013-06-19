//
//  CFavoriteViewController.h
//  Bus
//
//  Created by panda zheng on 13-5-7.
//  Copyright (c) 2013年 panda zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

enum ESegCtrlIndex
{
    EFavorite_Line,
    EFavorite_Stat,
    EFavorite_StatToStat
}segCtrlIndex;

@interface CFavoriteViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *favoriteTableView;
    UINavigationBar *favNavigationBar;
    UISegmentedControl *favoriteSegCtrl;
    
    NSInteger ESegType;
}

@property (nonatomic,strong) IBOutlet UITableView *favoriteTableView;
@property (nonatomic,strong) IBOutlet UISegmentedControl *favoriteSegCtrl;
@property (nonatomic,strong) IBOutlet UINavigationBar *favNavigationBar;


- (IBAction) OnSegmentIndexChanged: (id) sender;

@end
