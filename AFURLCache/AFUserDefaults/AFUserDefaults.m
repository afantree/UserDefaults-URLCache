//
//  AFUserDefaults.m
//  AFUserDefaults
//
//  Created by 阿凡树 QQ：729397005 on 14-5-21.
//  Copyright (c) 2014年 ManGang. All rights reserved.
//

#import "AFUserDefaults.h"
static AFUserDefaults *_afUserDefaults=nil;
@interface AFUserDefaults()
{
    FMDatabaseQueue           *_AFDatabaseQueue;
}
@end
@implementation AFUserDefaults
-(void)createTheDatabase
{
    //建表
    NSArray* sqlCreateArray = @[//------------------ 表 ----------------------
                                @"CREATE TABLE IF NOT EXISTS AFUserDefaults (id INTEGER  PRIMARY KEY AUTOINCREMENT DEFAULT NULL,key TEXT DEFAULT NULL,value BLOB DEFAULT NULL);",
                                //------------------索引----------------------
                                @"CREATE UNIQUE INDEX IF NOT EXISTS AFUserDefaults_index ON AFUserDefaults(key);"
                                ];
    
    for (NSString* str in sqlCreateArray) {
        [_AFDatabaseQueue inDatabase:^(FMDatabase *db) {
            if ([db executeUpdate:str]) {
                NSLog(@"Create OK!");
            };
        }];
    }
}
#pragma mark - custom
- (id)objectForKey:(NSString *)defaultName
{
    __block NSData* tempData = nil;
    [_AFDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT value FROM AFUserDefaults WHERE key = ?",defaultName];
        while ([rs next]) {
            tempData = [rs dataForColumn:@"value"];
        }
    }];
    NSDictionary* resultDict = nil;
    //NSLog(@"tempData=%@",tempData);
    if (tempData != nil) {
        resultDict =[NSKeyedUnarchiver unarchiveObjectWithData:tempData];
    }
    //NSLog(@"resultDict=%@",resultDict);
    return [resultDict objectForKey:@"value"];
}
- (void)setObject:(id)value forKey:(NSString *)defaultName
{
    [_AFDatabaseQueue inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"REPLACE INTO AFUserDefaults(key,value) VALUES (?,?);",defaultName,[NSKeyedArchiver archivedDataWithRootObject:@{@"value": value}]]) {
            NSLog(@"insert OK");
        }
    }];
}
- (void)removeObjectForKey:(NSString *)defaultName
{
    [_AFDatabaseQueue inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"DELETE FROM AFUserDefaults WHERE key = ?",defaultName]) {
            NSLog(@"remove OK!");
        };
    }];
}
#pragma mark - common
- (id)initWithFMDatabaseQueue:(FMDatabaseQueue*)databaseQueue
{
    self=[super init];
    if (self) {
        _AFDatabaseQueue = databaseQueue;
        [self createTheDatabase];
    }
    return self;
}
+ (id)createWithFMDatabaseQueue:(FMDatabaseQueue*)databaseQueue
{
    static dispatch_once_t predUserDefaults;
    dispatch_once(&predUserDefaults, ^{
        _afUserDefaults=[[AFUserDefaults alloc] initWithFMDatabaseQueue:databaseQueue];
    });
    return _afUserDefaults;
}
+ (id)standardUserDefaults{
    NSAssert(_afUserDefaults != nil, @"这个类必须用createWithFMDatabaseQueue:来初始化.");
	return _afUserDefaults;
}

+(id)alloc
{
	NSAssert(_afUserDefaults == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}
@end
