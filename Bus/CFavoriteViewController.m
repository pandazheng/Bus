//
//  CFavoriteViewController.m
//  Bus
//
//  Created by panda zheng on 13-5-7.
//  Copyright (c) 2013年 panda zheng. All rights reserved.
//

#import "CFavoriteViewController.h"
#import "CDataContainer.h"
#import "CBus_LineDetailViewController.h"
#import "CBus_StationDetailViewController.h"


@interface CFavoriteViewController ()

@end

@implementation CFavoriteViewController
@synthesize favoriteTableView,favoriteSegCtrl,favNavigationBar;

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
    ESegType = EFavorite_Line;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(toggleEdit:)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (IBAction) toggleEdit: (id) sender
{
    [self.favoriteTableView setEditing:!self.favoriteTableView.editing animated:YES];
    
    if (self.favoriteTableView.editing)
    {
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setTitle:@"Delete"];
    }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	[favoriteTableView reloadData];
	
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	NSInteger styleNum = [userDefault integerForKey:@"styleType"];
	
	switch (styleNum) {
		case 0:{
			[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
			self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
			self.favoriteSegCtrl.tintColor = [UIColor colorWithRed:0.48	green:0.56 blue:0.66 alpha:1.0];
			self.favNavigationBar.barStyle = UIBarStyleDefault;
			break;
		}
		case 1:{
			[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
			self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
			self.favoriteSegCtrl.tintColor = [UIColor darkGrayColor];
			self.favNavigationBar.barStyle = UIBarStyleBlackOpaque;
			break;
		}
	}
	
	[favoriteTableView reloadData];
}

#pragma mark -
#pragma mark Table view data source


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (ESegType == EFavorite_Line){
		return @"收藏线路";
	}
	else if(ESegType == EFavorite_Stat){
		return @"收藏站点";
	}
	else if(ESegType == EFavorite_StatToStat){
		return @"收藏站站";
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (ESegType == EFavorite_Line){
		return [[CDataContainer Instance].favoriteLineNameArray count];
	}
	else if(ESegType == EFavorite_Stat){
		return [[CDataContainer Instance].favoriteStationNameArray count];
	}
	else if(ESegType == EFavorite_StatToStat){
		return [[CDataContainer Instance].favoriteStatToStatBeginNameArray count];
	}
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FavoriteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure the cell...
	if (ESegType == EFavorite_Line){
		[[CDataContainer Instance] GetLineStationFromTableSequence:
		 [[[CDataContainer Instance].favoriteLineIndexArray objectAtIndex:indexPath.row] intValue]];
		
		NSString *beginStr = [[CDataContainer Instance].stationNameArray objectAtIndex:
                              [[CDataContainer Instance] GetBusLineSequenceByIndex:0]-1];
		
		NSString *endStr = [[CDataContainer Instance].stationNameArray objectAtIndex:
                            [[CDataContainer Instance] GetBusLineSequenceByIndex:[[CDataContainer Instance].sequenceNumArray count]-1]-1];
		
		NSString *detailStr = [[NSString alloc] initWithFormat:@"%@->%@",beginStr,endStr];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		cell.detailTextLabel.text = detailStr;

		
		cell.imageView.image = [UIImage imageNamed:@"bus_table_line.png"];
		cell.textLabel.text = [[CDataContainer Instance].favoriteLineNameArray objectAtIndex:indexPath.row];
	}
	else if(ESegType == EFavorite_Stat){
		cell.detailTextLabel.text = @"";
		cell.imageView.image = [UIImage imageNamed:@"bus_table_stat.png"];
		cell.textLabel.text = [[CDataContainer Instance].favoriteStationNameArray objectAtIndex:indexPath.row];
	}
	else if(ESegType == EFavorite_StatToStat){
		cell.detailTextLabel.text = @"";
		cell.imageView.image = [UIImage imageNamed:@"bus_statTostat.png"];
		
		NSString *beginStr = [[CDataContainer Instance].favoriteStatToStatBeginNameArray objectAtIndex:indexPath.row];
		NSString *endStr   = [[CDataContainer Instance].favoriteStatToStatEndNameArray objectAtIndex:indexPath.row];
		NSString *detailStr= [[NSString alloc] initWithFormat:@"%@->%@",beginStr,endStr];
		cell.textLabel.text = detailStr;
	}
	
    return cell;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        // Delete the row from the data source.
		
		if (ESegType == EFavorite_Line) {
			[[CDataContainer Instance] DeleteFavoriteInfoToDatabase:0
														 DeleteName:[[CDataContainer Instance].favoriteLineNameArray objectAtIndex:indexPath.row]
													  DeteleNameEnd:nil];
            
			[[CDataContainer Instance].favoriteLineNameArray removeObjectAtIndex:indexPath.row];
			[[CDataContainer Instance].favoriteLineIndexArray removeObjectAtIndex:indexPath.row];
		}
		else if(ESegType == EFavorite_Stat){
			[[CDataContainer Instance] DeleteFavoriteInfoToDatabase:1
														 DeleteName:[[CDataContainer Instance].favoriteStationNameArray objectAtIndex:indexPath.row]
													  DeteleNameEnd:nil];
			[[CDataContainer Instance].favoriteStationNameArray removeObjectAtIndex:indexPath.row];
			[[CDataContainer Instance].favoriteStationIndexArray removeObjectAtIndex:indexPath.row];
		}
		else if(ESegType == EFavorite_StatToStat){
			[[CDataContainer Instance] DeleteFavoriteInfoToDatabase:2
														 DeleteName:[[CDataContainer Instance].favoriteStatToStatBeginNameArray objectAtIndex:indexPath.row]
													  DeteleNameEnd:[[CDataContainer Instance].favoriteStatToStatEndNameArray objectAtIndex:indexPath.row]];
			
			[[CDataContainer Instance].favoriteStatToStatBeginNameArray removeObjectAtIndex:indexPath.row];
			[[CDataContainer Instance].favoriteStatToStatBeginIndexArray removeObjectAtIndex:indexPath.row];
			[[CDataContainer Instance].favoriteStatToStatEndNameArray removeObjectAtIndex:indexPath.row];
			[[CDataContainer Instance].favoriteStatToStatEndIndexArray removeObjectAtIndex:indexPath.row];
		}
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
	else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}   
}

/*
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (tableView == self.searchDisplayController.searchResultsTableView)
    //    {
    [self performSegueWithIdentifier:@"ShowStatCell" sender:self];
    //    }
}*/

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    indexPath = [self.favoriteTableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"ShowFavLineDetail"])
    {
        if (ESegType == EFavorite_Line)
        {
            CBus_LineDetailViewController *detailViewController = segue.destinationViewController;
            detailViewController.currentLineIndex = [[[CDataContainer Instance].favoriteLineIndexArray objectAtIndex:indexPath.row] intValue];
            detailViewController.currentLineName = [[CDataContainer Instance].favoriteLineNameArray objectAtIndex:indexPath.row];
            detailViewController.hidesBottomBarWhenPushed = YES;
        }
        /*
        CBus_StationDetailViewController *detailViewController = segue.destinationViewController;
        indexPath = [self.busStatToStatTableView indexPathForSelectedRow];
        detailViewController.currentStationName = [[CDataContainer Instance].stationNameArray
                                                   objectAtIndex:indexPath.row];
        detailViewController.currentStationIndex = indexPath.row + 1;
        detailViewController.hidesBottomBarWhenPushed = YES;*/
    }
    else if([segue.identifier isEqualToString:@"ShowFavStationDetail"])
    {
        if (ESegType == EFavorite_Stat)
        {
            CBus_StationDetailViewController *detailViewController = segue.destinationViewController;
            detailViewController.currentStationIndex = [[[CDataContainer Instance].favoriteStationIndexArray objectAtIndex:indexPath.row] intValue];
            detailViewController.currentStationName = [[CDataContainer Instance].favoriteStationNameArray objectAtIndex:indexPath.row];
            detailViewController.hidesBottomBarWhenPushed = YES;
        }
        else if (ESegType == EFavorite_StatToStat)
        {
            CBus_StationDetailViewController *detailViewController = segue.destinationViewController;
            detailViewController.beginStationName = [[CDataContainer Instance].favoriteStatToStatBeginNameArray objectAtIndex:indexPath.row];
            detailViewController.beginStationIndex = [[[CDataContainer Instance].favoriteStatToStatBeginIndexArray objectAtIndex:indexPath.row] intValue];
            
            detailViewController.endStationName = [[CDataContainer Instance].favoriteStatToStatEndNameArray objectAtIndex:indexPath.row];
            detailViewController.endStationIndex = [[[CDataContainer Instance].favoriteStatToStatEndIndexArray objectAtIndex:indexPath.row] intValue];
            
            detailViewController.isStatToStat = YES;
            detailViewController.hidesBottomBarWhenPushed = YES;
        }
    }
}



-(IBAction)OnSegmentIndexChanged:(id)sender{
	if ([sender selectedSegmentIndex] == 0){
		ESegType = EFavorite_Line;
	}
	else if([sender selectedSegmentIndex] == 1){
		ESegType = EFavorite_Stat;
	}
	else if([sender selectedSegmentIndex] == 2){
		ESegType = EFavorite_StatToStat;
	}
    
	[favoriteTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
