//
//  ViewController.m
//  Bus
//
//  Created by panda zheng on 13-4-22.
//  Copyright (c) 2013年 panda zheng. All rights reserved.
//

#import "ViewController.h"
#import "CDataContainer.h"
#import "CBus_LineDetailViewController.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize busLineTableView,filteredListContent;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[[CDataContainer Instance].lineNameArray count]];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.busLineTableView reloadData];
    
	NSLog(@"-----Nav------%@",self.navigationController.viewControllers);
	
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
	
	[self.busLineTableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return @"公交线路";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if(tableView == self.searchDisplayController.searchResultsTableView){
		return [filteredListContent count];
	}
	else {
		return [[CDataContainer Instance].lineNameArray count];
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"BusCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
//    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    // Configure the cell...
    
	if (tableView == self.searchDisplayController.searchResultsTableView){
		[[CDataContainer Instance] GetLineStationFromTableSequence:
		 [[CDataContainer Instance].lineNameArray indexOfObject:[filteredListContent objectAtIndex:indexPath.row]]];
		
		NSString *beginStr = [[CDataContainer Instance].stationNameArray objectAtIndex:
							  [[CDataContainer Instance] GetBusLineSequenceByIndex:0]-1];
		NSString *endStr = [[CDataContainer Instance].stationNameArray objectAtIndex:
							[[CDataContainer Instance] GetBusLineSequenceByIndex:[[CDataContainer Instance].sequenceNumArray count]-1]-1];
		
		NSString *detailStr = [[NSString alloc] initWithFormat:@"%@-->%@",beginStr,endStr];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		cell.detailTextLabel.text = detailStr;

		
		cell.textLabel.text = [filteredListContent objectAtIndex:indexPath.row];
	}
	else{
		[[CDataContainer Instance] GetLineStationFromTableSequence:indexPath.row];
        
		NSString *beginStr = [[CDataContainer Instance].stationNameArray objectAtIndex:
							  [[CDataContainer Instance] GetBusLineSequenceByIndex:0]-1];
		
		NSString *endStr = [[CDataContainer Instance].stationNameArray objectAtIndex:
							[[CDataContainer Instance] GetBusLineSequenceByIndex:[[CDataContainer Instance].sequenceNumArray count]-1]-1];
		
		NSString *detailStr = [[NSString alloc] initWithFormat:@"%@-->%@",beginStr,endStr];
 //       NSLog(@"%@--->%@",beginStr,endStr);
		cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		cell.detailTextLabel.text = detailStr;
		
		cell.textLabel.text = [[CDataContainer Instance].lineNameArray objectAtIndex:indexPath.row];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.imageView.image = [UIImage imageNamed:@"bus_table_line.png"];

    
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (tableView == self.searchDisplayController.searchResultsTableView)
//    {
        [self performSegueWithIdentifier:@"showBusCell" sender:self];
//    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBusCell"])
    {
        NSIndexPath *indexPath = nil;
        CBus_LineDetailViewController *detailViewController = segue.destinationViewController;
        
        if (busLineTableView == self.searchDisplayController.searchResultsTableView)
        {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            detailViewController.currentLineName = [filteredListContent objectAtIndex:indexPath.row];
            detailViewController.currentLineIndex = [[CDataContainer Instance].lineNameArray indexOfObject:[filteredListContent objectAtIndex:indexPath.row]];
        }
        else
        {
            indexPath = [self.busLineTableView indexPathForSelectedRow];
            detailViewController.currentLineName = [[CDataContainer Instance].lineNameArray
                                                    objectAtIndex:indexPath.row];
            detailViewController.currentLineIndex = indexPath.row;
        }
        detailViewController.hidesBottomBarWhenPushed = YES;
    }
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	// First clear the filtered array.
	[self.filteredListContent removeAllObjects];
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    
	for (int i = 0; i < [[CDataContainer Instance].lineNameArray count]; i++){
		NSString * searchInfo = [[CDataContainer Instance].lineNameArray objectAtIndex:i];
		
		NSComparisonResult result = [searchInfo compare:searchText
												options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
												  range:NSMakeRange(0, [searchText length])];
		
		if (result == NSOrderedSame){
			[self.filteredListContent addObject:searchInfo];
		}
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}



@end
