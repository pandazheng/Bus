//
//  CBus_LineDetailViewController.m
//  Bus
//
//  Created by panda zheng on 13-4-23.
//  Copyright (c) 2013年 panda zheng. All rights reserved.
//

#import "CBus_LineDetailViewController.h"
#import "CDataContainer.h"
#import "CBus_LineDetailLineViewController.h"

@interface CBus_LineDetailViewController ()

@end

@implementation CBus_LineDetailViewController
@synthesize busLineDetailTableView,currentLineName;
@synthesize currentLineIndex;


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
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(AddLineToFavorite)];
    [[CDataContainer Instance] GetLineStationFromTableSequence:currentLineIndex];
}

#pragma mark -
#pragma mark View liftcycle

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.busLineDetailTableView reloadData];
 
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
	
	[[CDataContainer Instance] GetLineStationFromTableSequence:currentLineIndex];
    [self.busLineDetailTableView reloadData];
	
	NSLog(@"-----Nav----%@",self.navigationController.viewControllers);
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) AddLineToFavorite
{
    NSLog(@"-------------addLineToFavorite----------------%@-----%d",currentLineName,currentLineIndex);
    
    for (NSString *lineName in [CDataContainer Instance].favoriteLineNameArray)
    {
        if ([lineName isEqualToString:currentLineName])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"收藏" message:[NSString stringWithFormat:@"%@ 已收藏",currentLineName] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            
            return;
        }
    }
    
    [[CDataContainer Instance] InsertFavoriteInfoToDatabase:0 AddName:currentLineName AddIndex:currentLineIndex AddNameEnd:nil AddIndexEnd:0];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"收藏" message:[NSString stringWithFormat:@"收藏 %@ 成功",currentLineName] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark -
#pragma mark Table View Data Source

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return currentLineName;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection:(NSInteger)section
{
    return [[CDataContainer Instance].sequenceNumArray count];
}

//Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"DetailBusCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
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
    [self performSegueWithIdentifier:@"showBusDetailCell" sender:self];
    //    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBusDetailCell"])
    {
        NSIndexPath *indexPath = nil;
        CBus_LineDetailLineViewController *detailViewController = segue.destinationViewController;
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
    self.busLineDetailTableView = nil;
}

@end
