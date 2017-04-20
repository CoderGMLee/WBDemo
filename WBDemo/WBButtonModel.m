//
//  WBButtonModel.m
//  WBDemo
//
//  Created by GM on 17/3/7.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBButtonModel.h"

@implementation WBButtonModel


- (NSString *)dataValue {
    NSInteger num = [self numberWithHexString:_VariableValue];
    return [NSString stringWithFormat:@"%ld",num];
}

- (NSInteger)numberWithHexString:(NSString *)hexString{

    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];

    int hexNumber;

    sscanf(hexChar, "%x", &hexNumber);

    return (NSInteger)hexNumber;
}



@end
