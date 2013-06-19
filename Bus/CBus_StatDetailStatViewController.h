//
//  CBus_StatDetailStatViewController.h
//  Bus
//
//  Created by panda zheng on 13-4-25.
//  Copyright (c) 2013年 panda zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBus_StatDetailStatViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    
	UITableView		*busLineDetailTableView;
	
    //当前查询的线路的index
	NSInteger		currentLineIndex;
	NSString		*currentLineName;
	
	NSMutableArray	*upLineArray;
	NSMutableArray	*downLineArray;
    
    BOOL			isStatToStat;
}
@property(nonatomic, retain) IBOutlet 	UITableView		*busLineDetailTableView;

@property(nonatomic, retain)	NSString		*currentLineName;

@property(nonatomic)			NSInteger		currentLineIndex;
@property(nonatomic)			BOOL			isStatToStat;


-(void)AddLineToFavorite;


@end
