//
//  DMUtils.h
//  DMall
//
//  Created by wangzhenchao on 15/8/27.
//  Copyright (c) 2015年 wintech. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, DMNetworkStatus) {
    DMNetWorkenable = 0,
    DMNetWorkWifi = 1,
    DMNetWork2G = 2,
    DMNetWork3G_4G = 3,
    DMNetWorkOther = 4
};


typedef struct _DMUtils_t{
    
    NSString * (*getDMGitBuildNumber)();
    NSString * (*getOpenUDID)();
    NSString * (*getAppVersion)();
    NSString * (*getDeviceModel)();
    NSString * (*getSystemVersion)();
    NSString * (*getSystemName)();
    NSString * (*getDeviceName)();
    NSString * (*getUserAgent)();
    NSString * (*getScretStr)(NSString *desStr);
    NSString * (*getTimeNow)();
    NSString * (*getCarrierName)();
} DMUtils_t;

extern DMUtils_t DMUtils;