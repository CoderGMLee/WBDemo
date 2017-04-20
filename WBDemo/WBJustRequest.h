//
//  WBJustRequest.h
//  WBDemo
//
//  Created by GM on 17/3/29.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBJust.h"

@interface WBJustRequest : WBJust

@property (nonatomic, assign)int32_t request_type;
@property (nonatomic, assign)int32_t dest_addr;
@property (nonatomic, assign)int32_t dest_port;
@property (nonatomic, assign)int32_t dest_line;
- (instancetype)initWithType:(int32_t)requestType;
@end
