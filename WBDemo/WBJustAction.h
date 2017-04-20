//
//  WBJustAction.h
//  WBDemo
//
//  Created by GM on 17/3/29.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBJust.h"

@interface WBJustAction : WBJust
{
    int32_t _command;
    uint32_t _x;
    uint32_t _y;
    BOOL _isGroup;
}

@property (nonatomic, assign)int32_t VarMatrix;
- (instancetype)initWithCmd:(int32_t)cmd isGroup:(BOOL)isGroup;
@end
