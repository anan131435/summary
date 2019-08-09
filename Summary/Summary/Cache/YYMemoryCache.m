//
//  YYMemoryCache.m
//  Summary
//
//  Created by 韩志峰 on 2019/7/27.
//  Copyright © 2019 韩志峰. All rights reserved.
//

#import "YYMemoryCache.h"
#import <pthread.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <QuartzCore/QuartzCore.h>


static inline dispatch_queue_t YYMemoryCacheGetReleaseQueue(){
    return  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}
@interface YYLinkedMapNode : NSObject{
    @package
    __unsafe_unretained YYLinkedMapNode *prev;
    __unsafe_unretained YYLinkedMapNode *next;
    id key;
    id value;
    NSUInteger cost;
    NSTimeInterval time;
}
@end

@implementation YYLinkedMapNode

@end
/*这个类不是线程安全的*/
@interface YYLinkedMap : NSObject
{
    @package
    CFMutableDictionaryRef dic;
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    YYLinkedMapNode *head;
    YYLinkedMapNode *tail;
    BOOL releaseOnMain;
    BOOL releaseAsync;
}
- (void)insertNodeAtHead:(YYLinkedMapNode *)node;
- (void)bringNodeToHead:(YYLinkedMapNode *)node;
- (void)removeNode:(YYLinkedMapNode *)node;
- (YYLinkedMapNode *)removeTailNode;
- (void)removeAll;
@end

@implementation YYLinkedMap
- (instancetype)init{
    self = [super init];
    dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    releaseOnMain = false;
    releaseAsync = YES;
    return self;
}
- (void)dealloc{
    CFRelease(dic);
}
- (void)insertNodeAtHead:(YYLinkedMapNode *)node{
    CFDictionarySetValue(dic, (__bridge const void *)(node->key), (__bridge const void *)node);
    _totalCount ++;
    _totalCost += node ->cost;
    if (head){
        node -> next = head;
        head -> prev = node;
        head = node;
    }else{
        head = tail = node;
    }
}
- (void)bringNodeToHead:(YYLinkedMapNode *)node{
    
}
- (YYLinkedMapNode *)removeTailNode{
    if (!tail) {return nil;};
    YYLinkedMapNode *tempTail = tail;
    CFDictionaryRemoveValue(dic, (__bridge const void *)(tail -> key));
    _totalCost -= tail->cost;
    _totalCount --;
    if(head == tail){
        head = tail = nil;
    }else{
        tail = tail -> prev;
        tail -> next = nil;
    }
    return  tempTail;
}


@end




@implementation YYMemoryCache
{
    pthread_mutex_t lock;//互斥量
    YYLinkedMap *lru;
    dispatch_queue_t queue;
}

@synthesize releaseAsynchronously;
-(instancetype)init{
    self = [super init];
    pthread_mutex_init(&lock, NULL);
    lru = [YYLinkedMap new];
    queue = dispatch_queue_create("cache.memory", DISPATCH_QUEUE_SERIAL);
    _countLimit = NSUIntegerMax;
    _costLimit = NSUIntegerMax;
    _ageLimit = DBL_MAX;
    _autoTrimInterval = 5.0;
    _shouldRemoveAllObjectsOnMemoryWarning = YES;
    _shouldRemoveAllObjectsWhenEnteringBackground = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self trimRecursively];
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [lru removeAll];
    pthread_mutex_destroy(&lock);
}
- (NSUInteger)totalCost{
    pthread_mutex_lock(&lock);
    NSUInteger cost = lru -> _totalCost;
    pthread_mutex_unlock(&lock);
    return  cost;
}
- (NSUInteger)totalCount{
    pthread_mutex_lock(&lock);
    NSUInteger count = lru -> _totalCount;
    pthread_mutex_unlock(&lock);
    return  count;
}
- (void)setReleaseOnMainThread:(BOOL)releaseOnMainThread{
    pthread_mutex_lock(&lock);
    lru -> releaseOnMain = releaseOnMainThread;
    pthread_mutex_unlock(&lock);
}
- (BOOL)releaseAsynchronously{
    pthread_mutex_lock(&lock);
    BOOL result = lru -> releaseAsync;
    pthread_mutex_unlock(&lock);
    return result;
}
- (void)trimRecursively{
    
}
- (void)_appDidReceiveMemoryWarningNotification{
    
}
- (void)_appDidEnterBackgroundNotification{
    
}
- (void)trimToCost:(NSUInteger)cost{
    [self _trimToCost:cost];
}
- (void)_trimToCost:(NSUInteger)costLimit{
    BOOL finished = NO;
    pthread_mutex_lock(&lock);
    if (costLimit == 0){
        [lru removeAll];
        finished = YES;
    }else if (lru -> _totalCost <= costLimit){
        finished = YES;
    }
    pthread_mutex_unlock(&lock);
    if (finished) return;
    NSMutableArray *holder = [NSMutableArray new];
    while (!finished) {
        if (pthread_mutex_trylock(&lock) == 0){
            if (lru -> _totalCost > costLimit){
                YYLinkedMapNode *node = [lru removeTailNode];
                if (node){
                    [holder addObject:node];
                }
            }else{
                finished = YES;
            }
            pthread_mutex_unlock(&lock);
        }else{
            usleep(10 * 1000); // 10 ms
        }
    }
    if (holder.count){
        dispatch_queue_t queue = lru -> releaseOnMain ?
        dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
}
- (void)trimToAge:(NSUInteger)age{
    [self _trimToAge:age];
}
- (void)_trimToAge:(NSUInteger)ageLimit{
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();
    pthread_mutex_lock(&lock);
    if (ageLimit <= 0){
        [lru removeAll];
        finish = YES;
    }else if(!lru -> tail || (now - lru->tail->time) <= ageLimit){
        finish = YES;
    }
    pthread_mutex_unlock(&lock);
    if (finish) return;
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if(pthread_mutex_trylock(&lock) == 0){
            if (lru->tail && (now - lru->tail->time) > ageLimit){
                YYLinkedMapNode *node = [lru removeTailNode];
                if (node){
                    [holder addObject:node];
                }
            }else{
                finish = YES;
            }
        }else{
            usleep(10 * 1000);
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = lru->releaseOnMain ? dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}
@end
