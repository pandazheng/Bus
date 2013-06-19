//
//  CBus_LineDetailLineViewController.h
//  Bus
//
//  Created by panda zheng on 13-4-23.
//  Copyright (c) 2013年 panda zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBus_LineDetailLineViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
	UITableView		*busStationDetailView;
	
	NSInteger		currentStationIndex;
	NSString		*currentStationName;
	
	NSInteger		beginStationIndex;
	NSString		*beginStationName;
	
	NSInteger		endStationIndex;
	NSString		*endStationName;
	
	BOOL			isStatToStat;
	
	NSMutableArray	*beginStationLineArray;
	NSMutableArray	*endStationLineArray;
	
	NSMutableArray	*StatToStatLineArray;
}

@property(nonatomic, retain) IBOutlet 	UITableView	*busStationDetailView;
@property(nonatomic, retain) 	NSString		*currentStationName;
@property(nonatomic)			NSInteger		currentStationIndex;

@property(nonatomic, retain) 	NSString		*beginStationName;
@property(nonatomic)			NSInteger		beginStationIndex;

@property(nonatomic, retain) 	NSString		*endStationName;
@property(nonatomic)			NSInteger		endStationIndex;

@property(nonatomic)			BOOL			isStatToStat;

@property(nonatomic, retain)    NSMutableArray	*beginStationLineArray;
@property(nonatomic, retain)    NSMutableArray	*endStationLineArray;
@property(nonatomic, retain)    NSMutableArray	*StatToStatLineArray;


- (BOOL)findTwoStationInOneLine;
- (BOOL)findTwoStationInTwoLine;

@end
