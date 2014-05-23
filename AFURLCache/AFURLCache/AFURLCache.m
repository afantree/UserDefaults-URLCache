//
//  AFURLCache.m
//  AFURLCache
//
//  Created by 阿凡树 QQ：729397005 on 14-5-19.
//  Copyright (c) 2014年 ManGang. All rights reserved.
//

#import "AFURLCache.h"
#import "AFURLCacheConfig.h"
static AFURLCache *_afURLCache=nil;
@interface AFURLCache()
{
    FMDatabaseQueue           *_AFDatabaseQueue;
    AFURLCacheConfig          *_config;
    dispatch_queue_t           _arrayQueue;
    dispatch_group_t           _arrayGroup;
}
@end
@implementation AFURLCache
-(void)createTheDatabase
{
    //建表
    NSArray* sqlCreateArray = @[
                                //------------------ 表 ----------------------
                                @"CREATE TABLE IF NOT EXISTS AFURLCache (id INTEGER  PRIMARY KEY AUTOINCREMENT DEFAULT NULL,markKey Varchar(255) DEFAULT NULL,markURL Varchar(255),ETag Varchar(100),LastModified Varchar(100),content BLOB,timestamp INTEGER DEFAULT 0);",
                                //------------------索引----------------------
                                @"CREATE UNIQUE INDEX IF NOT EXISTS AFURLCache_markKey_index ON AFURLCache(markKey);",
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
- (void)updateURLCache
{
    [self updateURLCacheWithKeyArray:[_config.urlDict allKeys]];
}
- (void)updateURLCacheWithKeyArray:(NSArray*)keyArray
{
    for (NSString* key in keyArray) {
        dispatch_async(_arrayQueue, ^{
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_config.urlDict[key]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0f];
            NSHTTPURLResponse* response = nil;
            NSError* error = nil;
            [request setAllHTTPHeaderFields:[self getHeaderFieldsForKey:key]];
            NSLog(@"request = %@",[request allHTTPHeaderFields]);
            NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            //NSLog(@"received = %@",received);
            NSLog(@"response = %@",response);
            
            if (error) {
                NSLog(@"error = %@",error);
            }
            else{
                if (response.statusCode == 304) { //304
                    NSLog(@"304");
                    [_AFDatabaseQueue inDatabase:^(FMDatabase *db) {
                        if ([db executeUpdate:@"UPDATE AFURLCache SET timestamp = ? WHERE markKey = ?;",[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]],key]) {
                            NSLog(@"insert OK");
                        }
                    }];
                }
                else if(response.statusCode < 300 && response.statusCode >= 200){ //正常更新
                    NSLog(@"2XX");
                    NSDictionary* headerDict = [response allHeaderFields];
                    @try {
                        [_AFDatabaseQueue inDatabase:^(FMDatabase *db) {
                            if ([db executeUpdate:@"REPLACE INTO AFURLCache(markKey,markURL,ETag,LastModified,content,timestamp) VALUES (?,?,?,?,?,?);",key,[_config.urlDict objectForKey:key],((headerDict[@"ETag"] == nil)?(@"NULL"):(headerDict[@"ETag"])),((headerDict[@"Last-Modified"] == nil)?(@"NULL"):(headerDict[@"Last-Modified"])),received,[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]]) {
                                NSLog(@"insert OK");
                            }
                        }];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"exception = %@",exception);
                    }
                }
                else{
                    NSLog(@"%ld",(long)response.statusCode);
                }
            }
        });
    }
}
- (NSData*)dataFromCacheForKey:(NSString*)cacheKey
{
    __block NSData* tempData = nil;
    [_AFDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT content FROM AFURLCache WHERE markKey = ?",cacheKey];
        while ([rs next]) {
            tempData = [rs dataForColumn:@"content"];
        }
    }];
    return [tempData copy];
}
- (id)jsonDateFromCacheForKey:(NSString*)cacheKey
{
    NSError* error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:[self dataFromCacheForKey:cacheKey] options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"json Serialization Error = %@",error);
    }
    return object;
}
#pragma mark - Sqlite operation
- (NSDictionary*)getHeaderFieldsForKey:(NSString*)key
{
    __block NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
    [_AFDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT ETag,LastModified FROM AFURLCache WHERE markKey = ?",key];
        while ([rs next]) {
            NSLog(@"ETag = %@",[rs stringForColumn:@"ETag"]);
            NSLog(@"LastModified = %@",[rs stringForColumn:@"LastModified"]);
            if (![[rs stringForColumn:@"ETag"] isEqualToString:@"NULL"]) {
                [tempDict setObject:[rs stringForColumn:@"ETag"] forKey:@"If-None-Match"];
            }
            else if (![[rs stringForColumn:@"LastModified"] isEqualToString:@"NULL"]) {
                [tempDict setObject:[rs stringForColumn:@"LastModified"] forKey:@"If-Modified-Since"];
            }
        }
    }];
    return [tempDict copy];
}
#pragma mark - common
- (id)initWithFMDatabaseQueue:(FMDatabaseQueue*)databaseQueue
{
    self=[super init];
    if (self) {
        _AFDatabaseQueue = databaseQueue;
        [self createTheDatabase];
        _config = [[AFURLCacheConfig alloc] init];
        //建造一个队列
        _arrayQueue=dispatch_queue_create("AFURLCache",NULL);
        _arrayGroup=dispatch_group_create();
    }
    return self;
}
+ (id)createWithFMDatabaseQueue:(FMDatabaseQueue*)databaseQueue
{
    static dispatch_once_t predURLCache;
    dispatch_once(&predURLCache, ^{
        _afURLCache=[[AFURLCache alloc] initWithFMDatabaseQueue:databaseQueue];
    });
    return _afURLCache;
}
+ (id)sharedURLCache{
    NSAssert(_afURLCache != nil, @"这个类必须用createWithFMDatabaseQueue:来初始化.");
	return _afURLCache;
}

+(id)alloc
{
	NSAssert(_afURLCache == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}
@end
