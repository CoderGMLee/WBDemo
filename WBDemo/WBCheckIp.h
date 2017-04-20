//
//  WBCheckIp.h
//  WBDemo
//
//  Created by GM on 17/2/16.
//  Copyright © 2017年 GM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBCheckIp : NSObject

+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (NSString *)getPublicIPAddress;

+ (BOOL)isValidatIP:(NSString *)ipAddress;
+ (NSDictionary *)getIPAddresses;

@end
