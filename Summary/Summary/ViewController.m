//
//  ViewController.m
//  Summary
//
//  Created by 韩志峰 on 2019/7/27.
//  Copyright © 2019 韩志峰. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "Person.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
//获取并打印类的成员变量 属性 方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //获取成员变量
    unsigned int ivarCount = 0;
    Ivar * ivars = class_copyIvarList([Person class], &ivarCount);
    for (int i = 0; i < ivarCount; i ++) {
        Ivar ivar = ivars[i];
        NSLog(@"第%d个成员变量%s",i,ivar_getName(ivar));
    }
    free(ivars);
    //获取属性
    unsigned int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([Person class], &propertyCount);
    for (int i = 0; i < propertyCount; i ++) {
        
    }
    
}


@end
