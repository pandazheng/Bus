//
//  CBus_LineDetailLineViewController.m
//  Bus
//
//  Created by panda zheng on 13-4-23.
//  Copyright (c) 2013年 panda zheng. All rights reserved.
//

#import "CBus_LineDetailLineViewController.h"
#import "CDataContainer.h"
#import "CBus_LineDetailViewController.h"

@interface CBus_LineDetailLineViewController ()

@end

@implementation CBus_LineDetailLineViewController
@synthesize busStationDetailView;
@synthesize currentStationName,currentStationIndex;
@synthesize beginStationName,beginStationIndex,endStationName,endStationIndex;
@synthesize isStatToStat;
@synthesize beginStationLineArray, endStationLineArray, StatToStatLineArray;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																						   target:self
																						   action:@selector(AddStationToFavorite)];
	
	if (isStatToStat){
		NSLog(@"---------isStatToStat-------");
		
		[[CDataContainer Instance] GetStationLineFromTableSequence:beginStationIndex];
		beginStationLineArray = [NSMutableArray arrayWithArray:[CDataContainer Instance].stationLineArray];
		
		NSLog(@"---------beginStationLineArray-------%@",beginStationLineArray);
		
		[[CDataContainer Instance] GetStationLineFromTableSequence:endStationIndex];
		endStationLineArray = [NSMutableArray arrayWithArray:[CDataContainer Instance].stationLineArray];
		
		NSLog(@"---------endStationLineArray-------%@",endStationLineArray);
        
		if ([self findTwoStationInOneLine]){
			return;
		}
		else if([self findTwoStationInTwoLine]){
			return;
		}
	}
	else {
		NSLog(@"---------isStat-------");
		[[CDataContainer Instance] GetStationLineFromTableSequence:currentStationIndex];
	}
}

- (BOOL)findTwoStationInOneLine{
	NSLog(@"-------findTwoStationInOneLine------");
	
	if (StatToStatLineArray == nil){
		StatToStatLineArray = [[NSMutableArray alloc] init];
	}
	
	for (NSString *beginStationStr in beginStationLineArray){
		for(NSString *endStationStr in endStationLineArray){
			if ([beginStationStr isEqualToString:endStationStr]){
				[StatToStatLineArray addObject:beginStationStr];
				
				NSLog(@"-----------StatToStatLineArray--------%@",StatToStatLineArray);
			}
		}
	}
	
	if (StatToStatLineArray){
		return YES;
	}
	
	return NO;
}

- (BOOL)findTwoStationInTwoLine{
	return NO;
}

#pragma mark -
#pragma mark View lifecycle

/* */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.busStationDetailView reloadData];
    NSLog(@"-----Nav----%@",self.navigationController.viewControllers);
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	NSInteger styleNum = [userDefault integerForKey:@"styleType"];
	
	switch (styleNum){
		case 0:{
			[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
			self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
			self.searchDisplayController.searchBar.barStyle = UIBarStyleDefault;
			break;
		}
		case 1:{
			[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
			self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
			self.searchDisplayController.searchBar.barStyle = UIBarStyleBlackOpaque;
			break;
		}
	}
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)AddStationToFavorite{
	NSLog(@"-----AddStationToFavorite-----%@----%d",currentStationName,currentStationIndex);
	
	for(NSString *lineName in [CDataContainer Instance].favoriteStationNameArray){
		if ([lineName isEqualToString:currentStationName]){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"收藏"
															message:[NSString stringWithFormat:@"%@ 已收藏",currentStationName]
														   delegate:self
												  cancelButtonTitle:@"确定"
												  otherButtonTitles:nil];
			[alert show];
			
			return;
		}
		
	}
	
	[[CDataContainer Instance] InsertFavoriteInfoToDatabase:1 AddName:currentStationName AddIndex:currentStationIndex AddNameEnd:nil AddIndexEnd:0];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"收藏"
													message:[NSString stringWithFormat:@"收藏 %@ 成功",currentStationName]
												   delegate:self
										  cancelButtonTitle:@"确定"
										  otherButtonTitles:nil];
	[alert show];
	
}

#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (isStatToStat){
		return [[NSString alloc] initWithFormat:@"%@——>%@",beginStationName,endStationName];
	}
	else{
		return currentStationName;
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
	if (isStatToStat){
		return [StatToStatLineArray count];
	}
	else{
		return [[CDataContainer Instance].stationLineArray count];
	}
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"DetailLineCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
    
    // Configure the cell...
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	if (isStatToStat){
		cell.textLabel.text = [[CDataContainer Instance].lineNameArray objectAtIndex:
                               [[StatToStatLineArray objectAtIndex:indexPath.row] intValue]/2-1];
	}
	else{
		[[CDataContainer Instance] GetLineStationFromTableSequence:
         [[CDataContainer Instance].lineNameArray indexOfObject:[[CDataContainer Instance].lineNameArray objectAtIndex:
                                                                 [[CDataContainer Instance] GetBusStationLineByIndex:indexPath.row]-1]]];
		
		NSString *beginStr = [[CDataContainer Instance].stationNameArray objectAtIndex:
                              [[CDataContainer Instance] GetBusLineSequenceByIndex:0]-1];
		
		NSString *endStr = [[CDataContainer Instance].stationNameArray objectAtIndex:
                            [[CDataContainer Instance] GetBusLineSequenceByIndex:[[CDataContainer Instance].sequenceNumArray count]-1]-1];
		
		NSString *detailStr = [[NSString alloc] initWithFormat:@"%@-->%@",beginStr,endStr];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		cell.detailTextLabel.text = detailStr;

		
		cell.textLabel.text = [[CDataContainer Instance].lineNameArray objectAtIndex:
                               [[CDataContainer Instance] GetBusStationLineByIndex:indexPath.row]-1];
	}
	
	cell.imageView.image = [UIImage imageNamed:@"bus_table_line.png"];
    
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (tableView == self.searchDisplayController.searchResultsTableView)
    //    {
    [self performSegueWithIdentifier:@"showBusDetailLine" sender:self];
    //    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBusDetailLine"])
    {
        NSIndexPath *indexPath = nil;
        CBus_LineDetailViewController *lineDetailViewController = segue.destinationViewController;
        indexPath = [self.busStationDetailView indexPathForSelectedRow];
        lineDetailViewController.currentLineName = [[CDataContainer Instance].lineNameArray objectAtIndex:
                                                    [[CDataContainer Instance] GetBusStationLineByIndex:indexPath.row]-1];
        lineDetailViewController.currentLineIndex = [[CDataContainer Instance].lineNameArray indexOfObject:lineDetailViewController.currentLineName];
        lineDetailViewController.hidesBottomBarWhenPushed = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
