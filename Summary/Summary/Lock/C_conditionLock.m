//
//  C_conditionLock.m
//  Summary
//
//  Created by 韩志峰 on 2019/7/27.
//  Copyright © 2019 韩志峰. All rights reserved.
//

#import "C_conditionLock.h"
#import <pthread.h>

@interface C_conditionLock ()
{
    pthread_mutex_t mutex; //互斥量
    pthread_cond_t cond;
    int count;
}
@end

@implementation C_conditionLock
- (instancetype)init{
    self = [super init];
    if (self){
        pthread_mutex_init(&mutex, 0);
        pthread_cond_init(&cond, 0);
    }
    return self;
}
- (void)conditionLockTheory{
    [NSThread detachNewThreadSelector:@selector(conditionLockOne) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(conditionLockTwo) toTarget:self withObject:nil];
}
- (void)conditionLockOne{
    while (1) {
        pthread_mutex_lock(&mutex);
        if (count >= 10){
            NSLog(@"没有空间了");
            pthread_cond_wait(&cond, &mutex);//阻塞 但mutex 这个互斥量解锁
        }else{
            count ++;
        }
        pthread_mutex_unlock(&mutex);
    }
}
- (void)conditionLockTwo{
    while (1) {
        pthread_mutex_lock(&mutex);
        if (count >= 10){
            count --;
            NSLog(@"释放空间");
            pthread_cond_signal(&cond);
        }else{
            count ++;
        }
        pthread_mutex_unlock(&mutex);
    }
}
@end
