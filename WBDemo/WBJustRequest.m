//
//  WBJustRequest.m
//  WBDemo
//
//  Created by GM on 17/3/29.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBJustRequest.h"

@implementation WBJustRequest

- (instancetype)initWithType:(int32_t)requestType {

    if (self = [super init]) {
        self.packetType = 0x02;
        _request_type = requestType;
        _dest_line = 0;
        _dest_port = 0;
        _dest_addr = 0;
    }
    return self;
}

- (NSData *)getOther:(NSData *)data {
    
    NSMutableData * muteData = [[NSMutableData alloc] initWithData:data];

    [muteData appendBytes:&_request_type length:sizeof(_request_type)];
    [muteData appendBytes:&_dest_addr length:sizeof(_dest_addr)];
    [muteData appendBytes:&_dest_port length:sizeof(_dest_port)];
    [muteData appendBytes:&_dest_line length:sizeof(_dest_line)]; //28

    //补足
    [muteData appendData:[[NSMutableData alloc] initWithLength:228]];

    return muteData;
}

@end
