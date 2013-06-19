//
//  CDataContainer.h
//  Bus
//
//  Created by Wenter Zhu on 11-1-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

enum EStyleType
{
	EDefaultType,
	EBlackType,
};


@interface CDataContainer : UIViewController {

	sqlite3		*database;
	
	//站点表信息
	NSMutableArray	*stationNameArray;
	NSMutableArray  *stationPYArray;
	//线路表信息
	NSMutableArray	*lineNameArray;
	//区间表信息
	NSMutableArray	*sequenceNumArray;
	//站点所在的线路
	NSMutableArray	*stationLineArray;
	//收藏信息
	NSMutableArray	*favoriteLineNameArray;
	NSMutableArray	*favoriteLineIndexArray;
	NSMutableArray	*favoriteStationNameArray;
	NSMutableArray	*favoriteStationIndexArray;
	NSMutableArray	*favoriteStatToStatBeginNameArray;
	NSMutableArray	*favoriteStatToStatBeginIndexArray;
	NSMutableArray	*favoriteStatToStatEndNameArray;
	NSMutableArray	*favoriteStatToStatEndIndexArray;
	//所有城市
	NSMutableArray	*allCitysArray;
	//当前城市
	NSString		*currentCityName;
	//下载完成的城市名称
	NSMutableArray	*downloadCitysArray;
}

@property(nonatomic, retain)	NSMutableArray	*stationNameArray;
@property(nonatomic, retain)	NSMutableArray	*stationPYArray;
@property(nonatomic, retain)	NSMutableArray	*lineNameArray;
@property(nonatomic, retain)	NSMutableArray	*sequenceNumArray;
@property(nonatomic, retain)	NSMutableArray	*stationLineArray;

@property(nonatomic, retain)	NSMutableArray	*favoriteLineNameArray;
@property(nonatomic, retain)	NSMutableArray	*favoriteLineIndexArray;
@property(nonatomic, retain)	NSMutableArray	*favoriteStationNameArray;
@property(nonatomic, retain)	NSMutableArray	*favoriteStationIndexArray;
@property(nonatomic, retain)	NSMutableArray	*favoriteStatToStatBeginNameArray;
@property(nonatomic, retain)	NSMutableArray	*favoriteStatToStatBeginIndexArray;
@property(nonatomic, retain)	NSMutableArray	*favoriteStatToStatEndNameArray;
@property(nonatomic, retain)	NSMutableArray	*favoriteStatToStatEndIndexArray;

@property(nonatomic, retain)    NSMutableArray	*allCityArray;
@property(nonatomic, retain)    NSString		*currentCityName;
@property(nonatomic, retain)    NSMutableArray	*downloadCitysArray;

+(CDataContainer*)Instance;
+(void)releaseInstance;

-(void)clearData;

//Init
-(void)InitData;

//DataBase
-(void)CopyDatabaseIfNeeded;
-(BOOL)OpenDatabase;
-(void)CloseDatabase;

-(void)GetInfoFromTableLine:(sqlite3*)_database;
-(void)GetInfoFromTableStation:(sqlite3*)_database;

-(void)GetLineStationFromTableSequence:(NSInteger)lineNum;
-(void)GetStationLineFromTableSequence:(NSInteger)stationNum;

-(void)InsertFavoriteInfoToDatabase:(NSInteger)addType 
							AddName:(NSString*)addName 
						   AddIndex:(NSInteger)addIndex
						 AddNameEnd:(NSString*)addNameEnd
						AddIndexEnd:(NSInteger)addIndexEnd;

-(void)DeleteFavoriteInfoToDatabase:(NSInteger)deleteType 
						 DeleteName:(NSString*)deleteName
					  DeteleNameEnd:(NSString*)deteleNameEnd;

-(void)GetFavoriteInfoFromDatabase;

//DataSource
-(NSInteger)GetBusLineSequenceByIndex:(NSInteger)index;
-(NSInteger)GetBusStationLineByIndex:(NSInteger)index;


@end
