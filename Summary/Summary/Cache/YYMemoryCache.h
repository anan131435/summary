//
//  YYMemoryCache.h
//  Summary
//
//  Created by 韩志峰 on 2019/7/27.
//  Copyright © 2019 韩志峰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
 YYMemoryCache 是一个快速的内存缓存存储键值对
 相比于字典key被持有没有被复制
 接口类似于nscache 所有方法是线程安全的
 用到了LRU去提高命中率 时间复杂度O（1）
 */
@interface YYMemoryCache : NSObject

#pragma mark  属性


/*name of cache*/
@property (nonatomic, copy) NSString *name;
// the number of objects in cache 缓存对象的数量
@property (nonatomic, readonly) NSUInteger totalCount;
//占用内存大小
@property (nonatomic, readonly) NSUInteger totalCost;
/*缓存能容纳的最大对象个数，默认max*/
@property NSUInteger countLimit;
//最大的内存消耗
@property NSUInteger costLimit;
//最大过期时间
@property NSTimeInterval ageLimit;
//内存检测的时间间隔 5s
@property NSTimeInterval autoTrimInterval;
// defalut yes
@property BOOL shouldRemoveAllObjectsOnMemoryWarning;
@property BOOL shouldRemoveAllObjectsWhenEnteringBackground;
//收到内存警告后执行
@property (nonatomic, copy) void(^didReceiveMemoryWarningBloclk)(YYMemoryCache *cache);
//进入后台后执行
@property (nonatomic, copy) void(^didEnterBackgroundBlock)(YYMemoryCache *cache);
//是否在主线程释放 默认是no
@property BOOL releaseOnMainThread;
//是否异步释放 默认yes
@property  BOOL releaseAsynchronously;

#pragma mark - 存取方法
//缓存中是否包含key的对象
- (BOOL)containsObjectForKey:(id)key;
//返回跟key关联的对象
- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost;
- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;

#pragma mark -删除操作
//用LRU去删除对象，知道totalCount < limit
- (void)trimToCount:(NSUInteger)count;
- (void)trimToCost:(NSUInteger)cost;
- (void)trimToAge:(NSUInteger)age;
@end

NS_ASSUME_NONNULL_END
