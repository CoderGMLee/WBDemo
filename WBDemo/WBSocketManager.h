//
//  WBSocketManager.h
//  WBDemo
//
//  Created by GM on 17/3/9.
//  Copyright © 2017年 GM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBSocketManager : NSObject
+ (WBSocketManager *)sharedInstance;


/**
 监听广播，包括发送设备信息，以及通过TCP接受XML文件，当解析完成后，会发送通知  外部只需要监听 KNotiParseComplete 通知即可
 */
- (void)udpStartMonitor;

- (void)udpStopMonotor;

/**
 向中控机发送指令

 @param orderString 指令代码
 */
- (void)updSendOrder:(NSString *)orderString machineName:(NSString *)name;


- (void)updSendOrder:(NSString *)orderString machineName:(NSString *)name isGroupCommand:(BOOL)group;

//发送连续指令
- (void)sendSessionCommand:(NSString *)orderString machineName:(NSString *)name;
/**
 扫描网络下的所有中控机
 */
- (void)scanOther;

- (void)downloadComplete:(NSData *)totalData;

- (void)repeatMessageSendFinish;
@end
