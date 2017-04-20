//
//  WBJustAction.m
//  WBDemo
//
//  Created by GM on 17/3/29.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBJustAction.h"
#import "WBGroupCommand.h"
@implementation WBJustAction

- (instancetype)initWithCmd:(int32_t)cmd isGroup:(BOOL)isGroup{

    if (self = [super init]) {
        _command = cmd;
        _x = -1;
        _y = -1;
        _isGroup = isGroup;
        self.packetType = 0x07;
    }
    return self;
}

-(NSData *)getOther:(NSData *)data {

    NSMutableData * muteData = [[NSMutableData alloc] initWithData:data];
    if (_isGroup) {
        //是组合事件
        _VarMatrix=0x7788;
        _y = [[[WBGroupCommand sharedInstance] inChannel] intValue];    //可能会有问题
        _x = [[[WBGroupCommand sharedInstance] outChannel] intValue];
        if ([[[WBGroupCommand sharedInstance] getMatrixtype] isEqualToString:@"ASCII"]) {

            if (_x > 15) {

            } else {
                if(_x<10)  _x+=0x30;
                else    _x+=0x37; //这个是A--F的转换
                if(_y<10) _y+=0x30;
                else    _y+=0x37; //这个是A--F的转换
            }

        } else {

        }
    } else {
        _VarMatrix=0x0;
    }

    uint32_t z = _x<<8 | _y;

    [muteData appendBytes:&_command length:sizeof(_command)];
    [muteData appendBytes:&_VarMatrix length:sizeof(_VarMatrix)];
    [muteData appendBytes:&z length:sizeof(z)];
    [muteData appendData:[[NSMutableData alloc] initWithLength:232]];
    return muteData;
}

@end
