//
//  Person.h
//  Summary
//
//  Created by 韩志峰 on 2019/8/2.
//  Copyright © 2019 韩志峰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sex;
- (void)text1;
@end

NS_ASSUME_NONNULL_END
