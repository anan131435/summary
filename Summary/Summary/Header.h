//
//  Header.h
//  Summary
//
//  Created by 韩志峰 on 2019/7/27.
//  Copyright © 2019 韩志峰. All rights reserved.
//

#ifndef Header_h
#define Header_h
/*
 ios 多线程
 NSThread NSOPeration  GCD
 
 thread operation是面向对象的， GCD是C语言的集合
 
 threade可以实现小的操作 json->model
 operation 可以添加依赖关系 监听状态 finished execting canceld  blockOperation invacationOperation 自定义 main start. start 是对异常状态的处理,并对 finished做了监听  main是执行任务的地方
 thread operation的取消都是对节点的取消，不是真正的取消
 开启了线程，需要执行耗时任务或者延迟执行需要开始runloop
 
 GCD 串行队列 只能开启一个任务
 并行队列 可同时开启多个任务
 
 dispatch_group {1. 创建组 2.创建并发队列 3.添加任务(block  enter) 4. notifi} blockOperation + KVO
 
 dispatch_barrier_async 相当于串行队列的执行，只能执行当前任务
 dispatch_sync 不具备开启多线程的能力
 dispatch_asyn 会开启多线程
 代码执行完了 任务还在外面飘着要用信号量去强化
 */

#endif /* Header_h */
