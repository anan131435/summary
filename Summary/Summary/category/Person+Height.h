//
//  Person+Height.h
//  Summary
//
//  Created by 韩志峰 on 2019/8/2.
//  Copyright © 2019 韩志峰. All rights reserved.
//

#import "Person.h"
/*
 关联属性并没有添加实例变量到分类里面
 关联属性被存储到了一个全局的AssocaitionsManager里面
 
    AssocaitionsManager
    AssociationHashMap *_map    // objc_setAssocaiteObject
 
 
 
 所有的关联属性 获取关联属性 移除关联属性 都是通过一个AssocaitionsManager来操作，
 
 */
NS_ASSUME_NONNULL_BEGIN

@interface Person (Height)
@property (nonatomic, copy) NSString *height;
@end

NS_ASSUME_NONNULL_END
