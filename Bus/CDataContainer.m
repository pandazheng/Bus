    //
//  CDataContainer.m
//  Bus
//
//  Created by Wenter Zhu on 11-1-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CDataContainer.h"

#define Assert(cond, ...) do { if (!(cond)) { printf(__VA_ARGS__); assert(cond); } } while(0)

static	sqlite3_stmt	*get_station_statement = nil;
static	sqlite3_stmt	*get_line_statement = nil;
static	sqlite3_stmt	*get_sequence_statement = nil;
static	sqlite3_stmt	*get_stationLine_statement = nil;
static	sqlite3_stmt	*get_favoriteInfo_statement = nil;
static	sqlite3_stmt	*insert_favoriteLineInfo_statement = nil;
static	sqlite3_stmt	*insert_favoriteStatInfo_statement = nil;
static	sqlite3_stmt	*insert_favoriteStatToStatInfo_statement = nil;
static	sqlite3_stmt	*delete_favoriteLineInfo_statement = nil;
static	sqlite3_stmt	*delete_favoriteStatInfo_statement = nil;
static	sqlite3_stmt	*delete_favoriteStatToStatInfo_statement = nil;


static CDataContainer *instance;

@implementation CDataContainer

@synthesize stationNameArray, stationPYArray;
@synthesize lineNameArray, sequenceNumArray;
@synthesize stationLineArray;

@synthesize favoriteLineNameArray,favoriteLineIndexArray;
@synthesize favoriteStationNameArray,favoriteStationIndexArray;
@synthesize favoriteStatToStatBeginNameArray,favoriteStatToStatBeginIndexArray;
@synthesize favoriteStatToStatEndNameArray,favoriteStatToStatEndIndexArray;

@synthesize allCityArray,currentCityName,downloadCitysArray;


+(CDataContainer*)Instance{
	
	@synchronized(self){
		if (!instance){
			instance = [[CDataContainer alloc] init];
		}
		
		return instance;
	}
	
	return nil;
}

+(void)releaseInstance
{
	if (instance) {
		instance = nil;
	}
}

-(void)clearData
{
	[stationNameArray removeAllObjects];
	[stationPYArray removeAllObjects];
	
	[lineNameArray removeAllObjects];
	
	[sequenceNumArray removeAllObjects];
	
	[stationLineArray removeAllObjects];
	
	[favoriteLineNameArray removeAllObjects];
	[favoriteLineIndexArray removeAllObjects];
	[favoriteStationNameArray removeAllObjects];
	[favoriteStationIndexArray removeAllObjects];
	[favoriteStatToStatBeginNameArray removeAllObjects];
	[favoriteStatToStatBeginIndexArray removeAllObjects];
	[favoriteStatToStatEndNameArray removeAllObjects];
	[favoriteStatToStatEndIndexArray removeAllObjects];
	
	[allCitysArray removeAllObjects];
	[downloadCitysArray removeAllObjects];
	
	currentCityName = nil;
	
	get_station_statement = nil;
	get_line_statement = nil;
	get_sequence_statement = nil;
	get_stationLine_statement = nil;
	get_favoriteInfo_statement = nil;
	insert_favoriteLineInfo_statement = nil;
	insert_favoriteStatInfo_statement = nil;
	insert_favoriteStatToStatInfo_statement = nil;
	delete_favoriteLineInfo_statement = nil;
	delete_favoriteStatInfo_statement = nil;
	delete_favoriteStatToStatInfo_statement = nil;
}

-(void)InitData{
	NSUserDefaults	*userDefault = [NSUserDefaults standardUserDefaults];	

	allCityArray = [[NSMutableArray alloc] init];
	
	if ([userDefault stringForKey:@"currentCityName"] == nil) {
		currentCityName = [[NSString alloc] initWithFormat:@"西安"];
	}
	else {
		currentCityName = [userDefault stringForKey:@"currentCityName"];
	}

	downloadCitysArray = [[NSMutableArray alloc] initWithArray:[userDefault arrayForKey:@"downloadCitys"]];
	if([downloadCitysArray count] == 0){
		[downloadCitysArray addObject:@"西安"];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[self InitData];
	[self CopyDatabaseIfNeeded];
	[self GetInfoFromTableStation:database];
	[self GetInfoFromTableLine:database];
	[self GetFavoriteInfoFromDatabase];
}

//判断数据库是否存在，不存在Copy
- (void)CopyDatabaseIfNeeded{
	
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *currentCity = [[NSString alloc] initWithFormat:@"%@%@",currentCityName,@".db"];
    NSString *writableDBPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:currentCity];
	NSLog(@"writableDBPath-----%@",writableDBPath);
    success = [fileManager fileExistsAtPath:writableDBPath];
	
    if (success){
		[self OpenDatabase];
		return;
	}

    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:currentCity];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];

	
    if (!success){
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
	else {
		[self OpenDatabase];
	}
}

//打开数据库
-(BOOL)OpenDatabase{
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *currentCity = [[NSString alloc] initWithFormat:@"%@%@",currentCityName,@".db"];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:currentCity];
	NSLog(@"path-----%@",path);

	
    if(sqlite3_open([path UTF8String], &database) == SQLITE_OK){
		NSLog(@"------------open database success");
        return YES;
    } 
	else{
        sqlite3_close(database);
        NSLog(@"Error: open database file.");
        
		return NO;
    }
    return NO;
}

//取得Station表中数据
-(void) GetInfoFromTableStation:(sqlite3*)_database{
    if(get_station_statement == nil){
		const char *sql = "SELECT * FROM station";
		
        if (sqlite3_prepare_v2(_database, sql, -1, &get_station_statement, NULL) != SQLITE_OK){
            Assert(0, "Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	while(sqlite3_step(get_station_statement) == SQLITE_ROW){
		if (stationNameArray == nil){
			stationNameArray    = [[NSMutableArray alloc] init];
		}
		
		[stationNameArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_station_statement, 1)]];
		
		if (stationPYArray == nil){
			stationPYArray    = [[NSMutableArray alloc] init];
		}
		
		[stationPYArray   addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_station_statement, 3)]];
	}
	
    sqlite3_reset(get_station_statement);
}

//取得Line表中数据
-(void) GetInfoFromTableLine:(sqlite3*)_database{
	if(get_line_statement == nil){
		const char *sql = "select * from line where type='0'";
		
        if (sqlite3_prepare_v2(_database, sql, -1, &get_line_statement, NULL) != SQLITE_OK){
            Assert(0, "Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	while(sqlite3_step(get_line_statement) == SQLITE_ROW){
		if (lineNameArray == nil){
			lineNameArray    = [[NSMutableArray alloc] init];
		}
		
		[lineNameArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_line_statement, 1)]];
	}
	sqlite3_reset(get_line_statement);
}

//取得某线路的站点信息
-(void)GetLineStationFromTableSequence:(NSInteger)lineNum{
	lineNum = lineNum*2+1;
	sequenceNumArray = nil;
	
	if (get_sequence_statement == nil){
		const char	*sql = "select * from sequence where line=?";
		
		if (sqlite3_prepare_v2(database, sql, -1, &get_sequence_statement, NULL) != SQLITE_OK){
            Assert(0, "Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
	}
	sqlite3_bind_int(get_sequence_statement, 1,lineNum);

	while(sqlite3_step(get_sequence_statement) == SQLITE_ROW){
		if (sequenceNumArray == nil){
			sequenceNumArray    = [[NSMutableArray alloc] init];
		}
		
		[sequenceNumArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_sequence_statement, 2)]];
	}
	sqlite3_reset(get_sequence_statement);
}

//取得包含某站点的线路信息
-(void)GetStationLineFromTableSequence:(NSInteger)stationNum{
	stationLineArray = nil;
	
	if (get_stationLine_statement == nil){
		const char	*sql = "select * from sequence where station=?";
		
		if (sqlite3_prepare_v2(database, sql, -1, &get_stationLine_statement, NULL) != SQLITE_OK){
            Assert(0, "Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
	}
	
	sqlite3_bind_int(get_stationLine_statement, 1,stationNum);

	while(sqlite3_step(get_stationLine_statement) == SQLITE_ROW){
		if (stationLineArray == nil){
			stationLineArray    = [[NSMutableArray alloc] init];
		}
			
		[stationLineArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_stationLine_statement, 1)]];
	}
	
	sqlite3_reset(get_stationLine_statement);

	for (int i=[stationLineArray count]-1; i>=0; i--){
		if (i%2 == 0){
			[stationLineArray removeObjectAtIndex:i];
		}
	}
}

//插入收藏信息
-(void)InsertFavoriteInfoToDatabase:(NSInteger)addType 
							AddName:(NSString*)addName 
						   AddIndex:(NSInteger)addIndex
						 AddNameEnd:(NSString*)addNameEnd
						AddIndexEnd:(NSInteger)addIndexEnd{
	if (addType == 0){
		if(insert_favoriteLineInfo_statement == nil){
			const char *sql = "INSERT INTO Favorite (FavoriteLineName,FavoriteLineIndex) VALUES (?,?)";
			
			if (sqlite3_prepare_v2(database, sql, -1, &insert_favoriteLineInfo_statement, NULL) != SQLITE_OK){
				Assert(0, "Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_int(insert_favoriteLineInfo_statement, 2, addIndex);
		sqlite3_bind_text(insert_favoriteLineInfo_statement, 1, [addName UTF8String], -1, SQLITE_TRANSIENT);
		
		if (favoriteLineNameArray == nil) {
			favoriteLineNameArray = [[NSMutableArray alloc] init];
		}
		[favoriteLineNameArray addObject:addName];

		if(favoriteLineIndexArray == nil){
			favoriteLineIndexArray = [[NSMutableArray alloc]init];
		}
		[favoriteLineIndexArray addObject:[[NSString alloc]initWithFormat:@"%d",addIndex]];
		
		int success = sqlite3_step(insert_favoriteLineInfo_statement);
		
		sqlite3_reset(insert_favoriteLineInfo_statement);
		
		if(success != SQLITE_ERROR){
			NSLog(@"insert into database with message OK");
		}
		else{
			NSLog(@"Failed to insert into database with message");
		} 
	}
	else if(addType == 1){
		if(insert_favoriteStatInfo_statement == nil){
			const char *sql = "INSERT INTO Favorite (FavoriteStatName,FavoriteStatIndex) VALUES (?,?)";
			
			if (sqlite3_prepare_v2(database, sql, -1, &insert_favoriteStatInfo_statement, NULL) != SQLITE_OK){
				Assert(0, "Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_int(insert_favoriteStatInfo_statement, 2, addIndex);
		sqlite3_bind_text(insert_favoriteStatInfo_statement, 1, [addName UTF8String], -1, SQLITE_TRANSIENT);
		
		if (favoriteStationNameArray == nil) {
			favoriteStationNameArray = [[NSMutableArray alloc]init];
		}
		[favoriteStationNameArray addObject:addName];
		
		if (favoriteStationIndexArray == nil) {
			favoriteStationIndexArray = [[NSMutableArray alloc] init];
		}
		[favoriteStationIndexArray addObject:[[NSString alloc]initWithFormat:@"%d",addIndex]];
		
		int success = sqlite3_step(insert_favoriteStatInfo_statement);
		
		sqlite3_reset(insert_favoriteStatInfo_statement);
		
		if(success != SQLITE_ERROR){
			NSLog(@"insert into database with message OK");
		}
		else{
			NSLog(@"Failed to insert into database with message");
		} 
	}
	else if(addType == 2){
		if(insert_favoriteStatToStatInfo_statement == nil){
			const char *sql = "INSERT INTO Favorite (favoriteStatToStatBeginName,favoriteStatToStatBeginIndex,favoriteStatToStatEndName,favoriteStatToStatEndIndex) VALUES (?,?,?,?)";
			
			if (sqlite3_prepare_v2(database, sql, -1, &insert_favoriteStatToStatInfo_statement, NULL) != SQLITE_OK){
				Assert(0, "Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_int(insert_favoriteStatToStatInfo_statement, 2, addIndex);
		sqlite3_bind_text(insert_favoriteStatToStatInfo_statement, 1, [addName UTF8String], -1, SQLITE_TRANSIENT);	
		sqlite3_bind_int(insert_favoriteStatToStatInfo_statement, 4, addIndexEnd);
		sqlite3_bind_text(insert_favoriteStatToStatInfo_statement, 3, [addNameEnd UTF8String], -1, SQLITE_TRANSIENT);
		
		if (favoriteStatToStatBeginNameArray == nil) {
			favoriteStatToStatBeginNameArray = [[NSMutableArray alloc]init];
		}
		[favoriteStatToStatBeginNameArray addObject:addName];
		
		if (favoriteStatToStatBeginIndexArray == nil) {
			favoriteStatToStatBeginIndexArray = [[NSMutableArray alloc] init];
		}
		[favoriteStatToStatBeginIndexArray addObject:[[NSString alloc]initWithFormat:@"%d",addIndex]];
		
		if (favoriteStatToStatEndNameArray == nil) {
			favoriteStatToStatEndNameArray = [[NSMutableArray alloc] init];
		}
		[favoriteStatToStatEndNameArray addObject:addNameEnd];
		
		if (favoriteStatToStatEndIndexArray == nil) {
			favoriteStatToStatEndIndexArray = [[NSMutableArray alloc] init];
		}
		[favoriteStatToStatEndIndexArray addObject:[[NSString alloc]initWithFormat:@"%d",addIndexEnd]];
		
		int success = sqlite3_step(insert_favoriteStatToStatInfo_statement);
		
		sqlite3_reset(insert_favoriteStatToStatInfo_statement);
		
		if(success != SQLITE_ERROR){
			NSLog(@"insert into database with message OK");
		}
		else{
			NSLog(@"Failed to insert into database with message");
		} 
	}
}

//删除收藏信息
-(void)DeleteFavoriteInfoToDatabase:(NSInteger)deleteType 
						 DeleteName:(NSString*)deleteName
					  DeteleNameEnd:(NSString*)deteleNameEnd{
	if (deleteType == 0){
		if(delete_favoriteLineInfo_statement == nil){
			const char *sql = "DELETE FROM Favorite WHERE FavoriteLineName = ?";
			
			if (sqlite3_prepare_v2(database, sql, -1, &delete_favoriteLineInfo_statement, NULL) != SQLITE_OK){
				Assert(0, "Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_text(delete_favoriteLineInfo_statement, 1, [deleteName UTF8String], -1, SQLITE_TRANSIENT);
				
		int success = sqlite3_step(delete_favoriteLineInfo_statement);
		
		sqlite3_reset(delete_favoriteLineInfo_statement);
		
		if(success != SQLITE_ERROR){
			NSLog(@"delete into database with message OK");
		}
		else{
			NSLog(@"Failed to delete into database with message");
		} 
	}
	else if(deleteType == 1){
		if(delete_favoriteStatInfo_statement == nil){
			const char *sql = "DELETE FROM Favorite WHERE FavoriteStatName = ?";
			
			if (sqlite3_prepare_v2(database, sql, -1, &delete_favoriteStatInfo_statement, NULL) != SQLITE_OK) {
				Assert(0, "Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_text(delete_favoriteStatInfo_statement, 1, [deleteName UTF8String], -1, SQLITE_TRANSIENT);
		
		int success = sqlite3_step(delete_favoriteStatInfo_statement);
		
		sqlite3_reset(delete_favoriteStatInfo_statement);
		
		if(success != SQLITE_ERROR){
			NSLog(@"delete into database with message OK");
		}
		else{
			NSLog(@"Failed to delete into database with message");
		} 
	}
	else if(deleteType == 2){
		if(delete_favoriteStatToStatInfo_statement == nil){
			const char *sql = "DELETE FROM Favorite WHERE favoriteStatToStatBeginName = ? AND favoriteStatToStatEndName = ?";
			
			if (sqlite3_prepare_v2(database, sql, -1, &delete_favoriteStatToStatInfo_statement, NULL) != SQLITE_OK){
				Assert(0, "Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_text(delete_favoriteStatToStatInfo_statement, 1, [deleteName UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(delete_favoriteStatToStatInfo_statement, 2, [deteleNameEnd UTF8String], -1, SQLITE_TRANSIENT);

		int success = sqlite3_step(delete_favoriteStatToStatInfo_statement);
		
		sqlite3_reset(delete_favoriteStatToStatInfo_statement);
		
		if(success != SQLITE_ERROR){
			NSLog(@"delete into database with message OK");
		}
		else{
			NSLog(@"Failed to delete into database with message");
		}
	}
}

//取得收藏信息
-(void)GetFavoriteInfoFromDatabase{
	if(get_favoriteInfo_statement == nil){
		const char *sql = "select * from Favorite";
		
        if (sqlite3_prepare_v2(database, sql, -1, &get_favoriteInfo_statement, NULL) != SQLITE_OK) {
            Assert(0, "Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
	while(sqlite3_step(get_favoriteInfo_statement) == SQLITE_ROW) 
    {
		if (favoriteLineNameArray == nil) {
			favoriteLineNameArray = [[NSMutableArray alloc] init];
		}
		if (favoriteLineIndexArray == nil) {
			favoriteLineIndexArray = [[NSMutableArray alloc] init];
		}		
		if (favoriteStationNameArray == nil) {
			favoriteStationNameArray = [[NSMutableArray alloc] init];
		}
		if (favoriteStationIndexArray == nil) {
			favoriteStationIndexArray = [[NSMutableArray alloc] init];
		}
		
		if (favoriteStatToStatBeginNameArray == nil) {
			favoriteStatToStatBeginNameArray = [[NSMutableArray alloc] init];
		}
		if (favoriteStatToStatBeginIndexArray == nil) {
			favoriteStatToStatBeginIndexArray = [[NSMutableArray alloc] init];
		}		
		if (favoriteStatToStatEndNameArray == nil) {
			favoriteStatToStatEndNameArray = [[NSMutableArray alloc] init];
		}
		if (favoriteStatToStatEndIndexArray == nil) {
			favoriteStatToStatEndIndexArray = [[NSMutableArray alloc] init];
		}
		
		
		if (sqlite3_column_text(get_favoriteInfo_statement, 5) != nil) {
			[favoriteLineNameArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_favoriteInfo_statement, 5)]];
		}
		if (sqlite3_column_text(get_favoriteInfo_statement, 4) != nil) {
			[favoriteLineIndexArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_favoriteInfo_statement, 4)]];
		}
		if (sqlite3_column_text(get_favoriteInfo_statement, 7) != nil) {
			[favoriteStationNameArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_favoriteInfo_statement, 7)]];
		}
		if (sqlite3_column_text(get_favoriteInfo_statement, 6) != nil) {
			[favoriteStationIndexArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_favoriteInfo_statement, 6)]];
		}
		
		if (sqlite3_column_text(get_favoriteInfo_statement, 3) != nil) {
			[favoriteStatToStatBeginNameArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_favoriteInfo_statement, 3)]];
		}
		if (sqlite3_column_text(get_favoriteInfo_statement, 2) != nil) {
			[favoriteStatToStatBeginIndexArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_favoriteInfo_statement, 2)]];
		}
		if (sqlite3_column_text(get_favoriteInfo_statement, 1) != nil) {
			[favoriteStatToStatEndNameArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_favoriteInfo_statement, 1)]];
		}
		if (sqlite3_column_text(get_favoriteInfo_statement, 0) != nil) {
			[favoriteStatToStatEndIndexArray addObject:[NSString  stringWithUTF8String:(char*) sqlite3_column_text(get_favoriteInfo_statement, 0)]];
		}
	}
	sqlite3_reset(get_favoriteInfo_statement);
}

//关闭数据库
-(void)CloseDatabase{
	sqlite3_close(database);
}


#pragma mark ---
#pragma mark DataMethod

-(NSInteger)GetBusLineSequenceByIndex:(NSInteger)index{
	return [[sequenceNumArray objectAtIndex:index] intValue];
}

-(NSInteger)GetBusStationLineByIndex:(NSInteger)index{
	return [[stationLineArray objectAtIndex:index] intValue]/2;
}

///////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



@end
