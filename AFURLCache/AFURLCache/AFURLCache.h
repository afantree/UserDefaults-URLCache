//
//  AFURLCache.h
//  AFURLCache
//
//  Created by 阿凡树 QQ：729397005 on 14-5-19.
//  Copyright (c) 2014年 ManGang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AFURLCACHE [AFURLCache sharedURLCache]
@interface AFURLCache : NSObject

//初始化
+ (id)createWithFMDatabaseQueue:(FMDatabaseQueue*)databaseQueue;

+(id)sharedURLCache;

//更新数据
- (void)updateURLCache;
//通过Key值获取数据
- (NSData*)dataFromCacheForKey:(NSString*)cacheKey;
//如果是Json的话，直接用这个
- (id)jsonDateFromCacheForKey:(NSString*)cacheKey;

@end
