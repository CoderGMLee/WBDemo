//
//  WBJust.h
//  WBDemo
//
//  Created by GM on 17/3/29.
//  Copyright © 2017年 GM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBJust : NSObject
{
    int32_t _action;
}
@property (nonatomic, assign) int32_t packetSize;
@property (nonatomic, assign) int8_t packetType;
@property (nonatomic, assign) int32_t packetNumber;



- (NSData *)getData;
- (NSData *)getOther:(NSData *)data;
@end
