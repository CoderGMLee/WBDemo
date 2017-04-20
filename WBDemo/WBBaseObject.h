//
//  WBBaseObject.h
//  WBDemo
//
//  Created by GM on 17/3/7.
//  Copyright © 2017年 GM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBBaseObject : NSObject
@property (nonatomic, copy) NSString * type;
@property (nonatomic, copy) NSString * className;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * children;

//MARK:- custom
@property (nonatomic, copy) NSString * controlPageSize;

@end
