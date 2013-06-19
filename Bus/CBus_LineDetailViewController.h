//
//  CBus_LineDetailViewController.h
//  Bus
//
//  Created by panda zheng on 13-4-23.
//  Copyright (c) 2013年 panda zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBus_LineDetailViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *busLineDetailTableView;
    
    //当前查询的线路的index
    NSInteger currentLineIndex;
    NSString *currentLineName;
    
    NSInteger runType;
    NSMutableArray *upLineArray;
    NSMutableArray *downLineArray;
}

@property (nonatomic, retain) IBOutlet UITableView *busLineDetailTableView;
@property (nonatomic, retain) NSString *currentLineName;
@property (nonatomic) NSInteger currentLineIndex;

@end
