//
//  AFUserDefaults.h
//  AFURLCache
//
//  Created by 阿凡树 QQ：729397005 on 14-5-21.
//  Copyright (c) 2014年 ManGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#define AFUSERDEFAULTS [AFUserDefaults standardUserDefaults]
@interface AFUserDefaults : NSObject
{
}
//初始化
+ (id)createWithFMDatabaseQueue:(FMDatabaseQueue*)databaseQueue;

+ (NSUserDefaults *)standardUserDefaults;

- (id)objectForKey:(NSString *)defaultName;
- (void)setObject:(id)value forKey:(NSString *)defaultName;
- (void)removeObjectForKey:(NSString *)defaultName;

@end
