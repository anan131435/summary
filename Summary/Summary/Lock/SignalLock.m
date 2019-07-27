//
//  SignalLock.m
//  Summary
//
//  Created by 韩志峰 on 2019/7/27.
//  Copyright © 2019 韩志峰. All rights reserved.
//

#import "SignalLock.h"

@interface SignalLock ()
{
    NSLock *mutexLock; //互斥锁
    dispatch_semaphore_t sema;
    int count;
}
@end



@implementation SignalLock
- (instancetype)init{
    self = [super init];
    if (self) {
        mutexLock = [NSLock new];
        sema = dispatch_semaphore_create(0);
    }
    return self;
}
- (void)signalLock{
    [NSThread detachNewThreadSelector:@selector(threadOne) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(threadTwo) toTarget:self withObject:nil];
}
- (void)threadOne{
    [self signalLockWrite];
}
- (void)threadTwo{
    [self signalLockRead];
}
#pragma mark 信号量 + 互斥锁 锁死
- (void)signalLockWrite{
    while (1) {
        [mutexLock lock];
        if (count >= 10){
            NSLog(@"没有空间了");
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER); //阻塞
        }else{
            count ++;
            NSLog(@"占用空间：%d",count);
        }
        [mutexLock unlock];
    }
}
- (void)signalLockRead{
    while (1) {
        [mutexLock lock];
        if (count >= 10){
            count --;
            NSLog(@"释放空间");
            dispatch_semaphore_signal(sema);
        }else{
            count ++;
        }
        [mutexLock unlock];
    }
}
@end
