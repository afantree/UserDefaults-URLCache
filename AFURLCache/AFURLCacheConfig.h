//
//  AFURLCacheConfig.h
//  AFURLCache
//
//  Created by 阿凡树 QQ：729397005 on 14-5-19.
//  Copyright (c) 2014年 ManGang. All rights reserved.
//

#define KEY_URL_CATEGORY        @"KEY_URL_CATEGORY"
#define KEY_URL_IMAGE           @"KEY_URL_IMAGE"

@interface AFURLCacheConfig : NSObject
{
    int            _cacheTime;
    NSDictionary*  _urlDict;
}
//缓存时间
@property (readonly) int cacheTime;
//需要缓存数组的字典
@property (readonly) NSDictionary* urlDict;
@end
@implementation AFURLCacheConfig
- (id)init
{
    if (self = [super init]) {
        _cacheTime = 100;
        _urlDict = @{KEY_URL_CATEGORY:@"http://i.v.umiwi.com/Apireader/albumCategoryList",
                     KEY_URL_IMAGE:@"http://i1.umivi.net/v/album/2013-12/20131230185329.jpg"
                     };
    }
    return self;
}
@end
