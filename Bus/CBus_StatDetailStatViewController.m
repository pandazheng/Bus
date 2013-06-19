//
//  CBus_StatDetailStatViewController.m
//  Bus
//
//  Created by panda zheng on 13-4-25.
//  Copyright (c) 2013年 panda zheng. All rights reserved.
//

#import "CBus_StatDetailStatViewController.h"
#import "CBus_StationDetailViewController.h"
#import "CBus_LineDetailLineViewController.h"
#import "CDataContainer.h"

@interface CBus_StatDetailStatViewController ()

@end

@implementation CBus_StatDetailStatViewController
@synthesize busLineDetailTableView,currentLineName;
@synthesize currentLineIndex;
@synthesize isStatToStat;

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                                              action:@selector(AddLineToFavorite)];
    [[CDataContainer Instance] GetLineStationFromTableSequence:currentLineIndex];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.busLineDetailTableView reloadData];
    NSLog(@"-----Nav----%@",self.navigationController.viewControllers);
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	NSInteger styleNum = [userDefault integerForKey:@"styleType"];
	
	switch (styleNum) {
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
    isStatToStat = NO;
}

-(void)AddLineToFavorite{
	NSLog(@"-------addLineToFavorite---------%@---%d",currentLineName,currentLineIndex);
	
	for(NSString *lineName in [CDataContainer Instance].favoriteLineNameArray){
		if ([lineName isEqualToString:currentLineName]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"收藏"
															message:[NSString stringWithFormat:@"%@ 已收藏",currentLineName]
														   delegate:self
												  cancelButtonTitle:@"确定"
												  otherButtonTitles:nil];
			[alert show];
			return;
		}
	}
	
	[[CDataContainer Instance] InsertFavoriteInfoToDatabase:0 AddName:currentLineName AddIndex:currentLineIndex AddNameEnd:nil AddIndexEnd:0];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"收藏"
													message:[NSString stringWithFormat:@"收藏 %@ 成功",currentLineName]
												   delegate:self
										  cancelButtonTitle:@"确定"
										  otherButtonTitles:nil];
	[alert show];
}

#pragma mark -
#pragma mark Table View Data Source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return currentLineName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[CDataContainer Instance].sequenceNumArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"StatToStatDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure the cell...
    cell.textLabel.text = [[CDataContainer Instance].stationNameArray objectAtIndex:[[CDataContainer Instance] GetBusLineSequenceByIndex:indexPath.row]-1];
	cell.imageView.image = [UIImage imageNamed:@"bus_table_stat.png"];
    
	return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (tableView == self.searchDisplayController.searchResultsTableView)
    //    {
    [self performSegueWithIdentifier:@"ShowStatToStatDetail" sender:self];
    //    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowStatToStatDetail"])
    {
        NSIndexPath *indexPath = nil;
        CBus_StationDetailViewController *detailViewController = segue.destinationViewController;
        indexPath = [self.busLineDetailTableView indexPathForSelectedRow];
        
        detailViewController.currentStationName = [[CDataContainer Instance].stationNameArray objectAtIndex:[[CDataContainer Instance] GetBusLineSequenceByIndex:indexPath.row]-1];
        detailViewController.currentStationIndex = [[CDataContainer Instance].stationNameArray indexOfObject:detailViewController.currentStationName]+1;
        detailViewController.hidesBottomBarWhenPushed = YES;
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
