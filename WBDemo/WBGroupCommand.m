//
//  WBGroupCommand.m
//  WBDemo
//
//  Created by GM on 2017/3/31.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBGroupCommand.h"

@implementation WBGroupCommand

+ (WBGroupCommand *)sharedInstance {

    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[WBGroupCommand alloc] init];
    });
    return sharedInstance;
}

@end
