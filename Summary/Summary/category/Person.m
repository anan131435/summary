//
//  Person.m
//  Summary
//
//  Created by 韩志峰 on 2019/8/2.
//  Copyright © 2019 韩志峰. All rights reserved.
//

#import "Person.h"

@implementation Person

@synthesize name = _name;

- (void)text1{
    NSLog(@"%s",__func__);
}
- (void)text2{
    NSLog(@"%s",__func__);
}
- (void)setName:(NSString *)name{
    _name = name;
}
- (NSString *)name{
    return _name;
}
@end
