
//
//  WBJust.m
//  WBDemo
//
//  Created by GM on 17/3/29.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBJust.h"

@implementation WBJust

- (instancetype)init {

    if (self = [super init]) {
        _packetSize = 256;
        _packetType = 0 ;
        _action = 0x34;
        _packetNumber = 0;
    }
    return self;
}

- (NSData *)getData {
    NSMutableData * sockedData = [[NSMutableData alloc] init];

    int32_t packetSize = _packetSize;
    int8_t packetType = _packetType;
    int8_t packedAction = _action;
    int16_t crc = 0;
    int32_t packetNumber = _packetNumber;   //12

    [sockedData appendBytes:&packetSize length:sizeof(packetSize)];
    [sockedData appendBytes:&packetType length:sizeof(packetType)];
    [sockedData appendBytes:&packedAction length:sizeof(packedAction)];
    [sockedData appendBytes:&crc length:sizeof(crc)];
    [sockedData appendBytes:&packetNumber length:sizeof(packetNumber)];
    return [self getOther:sockedData];
}

- (NSData *)getOther:(NSData *)data {
    return [self getData];
}

@end
