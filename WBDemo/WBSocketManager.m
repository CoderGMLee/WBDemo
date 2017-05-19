//
//  WBSocketManager.m
//  WBDemo
//
//  Created by GM on 17/3/9.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBSocketManager.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "AsyncUdpSocket.h"
#import "AsyncSocket.h"
#import "WBCheckIp.h"
#import "DMUtils.h"
#import "GDataXMLNode.h"
#import "WBModelManager.h"
#import "WBParse.h"
#import "WBJust.h"
#import "WBJustRequest.h"
#import "WBJustAction.h"
#import <SVProgressHUD.h>
#import "WBFileManager.h"
#import "GCDAsyncSocket.h"
#import <arpa/inet.h>
#include <netinet/tcp.h>
#import "CommonHeader.h"
#import "DMTimer.h"
//广播tag
#define KUdpBroadTag 2000
//监听广播tag
#define KUdpBaseTag 1000
//接受xml文件soceket tag
#define KTcpReceiveTag  3000
//发送TCP指令
#define KTcpSendCommandTag 4000

#define KBoardAddress @"255.255.255.255"
#define KBoardPort 525
#define KMonitorPort 63000
#define KTcpPort 4544
#define KUdpMessagePort 10086

@interface WBSocketManager ()<AsyncSocketDelegate,GCDAsyncSocketDelegate>
{
    //监听PC的广播消息
    AsyncUdpSocket *_udpSocket;
    //给中控机发送广播消息
    AsyncUdpSocket *_broadUdpSocket;
    //接受PC的XML文件
//    AsyncSocket * _tcpSocket;

    NSMutableArray * _udpArray; //存放监听广播的udp
    NSMutableArray * _tcpArray;
    NSMutableData * _resultData;
    NSMutableDictionary * _machineDic;

    GCDAsyncSocket * _gcdTcpScoket;

    long long _totalLen;
}

@property (nonatomic, strong)NSMutableDictionary * cmdDic;
@property (nonatomic, strong)NSMutableDictionary * commandStateDic;
@property (nonatomic, strong)NSMutableArray * sessionSockets;
@property (nonatomic, strong)NSMutableArray * commandBroadArr;
@end


@implementation WBSocketManager

+ (WBSocketManager *)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WBSocketManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initTcpSocket];
        _udpArray = [NSMutableArray array];
        _tcpArray = [NSMutableArray array];
        _machineDic = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseError:) name:KNotiParseError object:nil];
    }
    return self;
}

- (void)initTcpSocket {
//    if (!_tcpSocket) {
//        _tcpSocket = [[AsyncSocket alloc] initWithDelegate:self];
//        NSError *error = nil;
//        BOOL ret = [_tcpSocket acceptOnPort:KTcpPort error:&error];
//        if (ret == NO) {
//            NSLog(@"tcp bind error is %@", error);
//        }
//        [_tcpSocket readDataWithTimeout:-1 tag:KTcpReceiveTag];;
//    }
    if (!_gcdTcpScoket) {
        _gcdTcpScoket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error = nil;
        BOOL ret = [_gcdTcpScoket acceptOnPort:KTcpPort error:&error];
        if (ret == NO) {
            NSLog(@"tcp bind error is %@", error);
        }
        [_gcdTcpScoket readDataWithTimeout:-1 tag:KTcpReceiveTag];;
    }
}

- (void)udpStartMonitor {

    _udpSocket = nil;
    if (!_udpSocket) {
        _udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    }

    NSError * error = nil;
    //可能需要绑定多个端口
    [_udpArray removeAllObjects];
    for (NSInteger i = 1; i<20; i++) {
        AsyncUdpSocket * udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        BOOL success = [udpSocket bindToPort:KMonitorPort+i error:nil];
        if (!success) {
            NSLog(@"失败");
        }
        [udpSocket receiveWithTimeout:-1 tag:KUdpBaseTag+i];
        [udpSocket enableBroadcast:true error:nil];
        [_udpArray addObject:udpSocket];
    }
    BOOL bindSuccess = [_udpSocket bindToPort:KMonitorPort error:&error];
    if (!bindSuccess) {
        NSLog(@"接口绑定失败 有可能是因为端口被占用");
        [SVProgressHUD showInfoWithStatus:@"接口绑定失败 有可能是因为端口被占用"];
    }
    [_udpSocket enableBroadcast:true error:nil];
    NSString * ipAddress = [WBCheckIp getIPAddress:true];
    NSLog(@"ipAddress : %@",ipAddress);
    [_udpSocket receiveWithTimeout:-1 tag:KUdpBaseTag];
}

- (void)udpStopMonotor {
    _udpSocket = nil;
    [_udpArray removeAllObjects];
}

- (void)sendMessageForResponse:(NSString *)host port:(NSInteger)port socket:(AsyncUdpSocket *)socket{
    //发送设备信息及ip给PC端
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSString * uuid = DMUtils.getOpenUDID();
    NSString * phoneName = DMUtils.getDeviceName();
    [dict setObject:uuid forKey:@"UUID"];
    [dict setObject:@"iOS" forKey:@"Platform"];
    [dict setObject:@"1.0" forKey:@"Version"];
    [dict setObject:@(KTcpPort) forKey:@"TcpPort"];
    [dict setObject:phoneName forKey:@"phoneName"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [_udpSocket sendData:jsonData toHost:host port:port withTimeout:-1 tag:1001];
}

#pragma mark - AsyncUdpSocketDelegate
//UDP 消息发送成功   发送广播
- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    if (tag == KUdpBroadTag) {
        [_broadUdpSocket receiveWithTimeout:-1 tag:KUdpBroadTag];
        [self.commandBroadArr addObject:sock];
        [sock receiveWithTimeout:-1 tag:KUdpBroadTag];
    } else {
        NSLog(@"tag : %ld 设备信息发送成功  count : %ld",tag,_udpArray.count);
    }
    [_udpArray addObject:sock];
    [sock receiveWithTimeout:-1 tag:KUdpBroadTag];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"设备信息发送失败 %s",__func__);
}

//UDP 收到消息  发送本机信息  收到PC消息和收到中控机的设备信息在这里处理
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    NSLog(@"收到UDP消息");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (tag >= KUdpBaseTag && tag <= KUdpBaseTag + 20) {
            //接收到电脑端的广播后发送自身的IP和端口给电脑
            NSLog(@"%s",__func__);
            [_udpSocket receiveWithTimeout:-1 tag:tag];
            [sock receiveWithTimeout:-1 tag:tag];
            [_udpArray addObject:sock];
            [self sendMessageForResponse:host port:port socket:sock];
        } else if (tag == KUdpBroadTag){
            //本身发出广播后，其他中控机返回的消息中包含IP和name
            [self saveMachineName:data];
            [_broadUdpSocket receiveWithTimeout:-1 tag:KUdpBroadTag];
        }
    });
    return true;
}


//MARk:- 保存设备信息
- (void)saveMachineName:(NSData *)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString * addressStr = [[NSMutableString alloc] init];
        NSInteger index = 16;
        if (data.length < 256) {
            return ;
        }
        for (NSInteger i = 0; i < 4; i++) {
            int header[1] = {};
            [data getBytes:header range:NSMakeRange(index, 1)];
            index++;
            int num = header[0];
            [addressStr appendString:[NSString stringWithFormat:@"%d",num]];
            if (i != 3) {
                [addressStr appendString:@"."];
            }
        }
        char str[40] = {};
        [data getBytes:str range:NSMakeRange(52, 40)];
        NSString * name = [NSString stringWithUTF8String:str];
        [_machineDic setObject:addressStr forKey:name];
    });
}

#pragma mark - AsyncSocketDelegate

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {

    [_tcpArray addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:KTcpReceiveTag];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    NSLog(@"%@",err.localizedDescription);
    _totalLen = 0;
    _resultData = nil;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    //向中控机发送指令
    [self sendCommand:host socked:sock];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == KTcpSendCommandTag) {
        NSLog(@"发送指令成功");
    }
}

//指令socket和文件传输socket断开链接都会调用
- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    [SVProgressHUD dismiss];
    NSLog(@"断开链接");
}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {

    dispatch_async(dispatch_get_main_queue(), ^{
        if (tag == KTcpReceiveTag) {
            NSLog(@"接收到XML数据  %lu",(unsigned long)data.length);
            if (_resultData) {
//                [SVProgressHUD showProgress:(CGFloat)_resultData.length / (CGFloat)_totalLen];
                [_resultData appendData:data];
            }
            if (!_resultData) {
                _resultData = [NSMutableData data];
                NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                _totalLen = [jsonDic[@"len"] longLongValue];
                NSString * downLoad = @"start download";
                [sock writeData:[downLoad dataUsingEncoding:NSUTF8StringEncoding] withTimeout:10 tag:KTcpReceiveTag];
            }
            [_tcpArray addObject:sock];
            if ( _resultData.length >= _totalLen && _totalLen != 0) {
                [self disconnectDownloadSocket:sock];
            };
            [sock readDataWithTimeout:10 tag:KTcpReceiveTag];
        }
    });
}

//断开下载文件的链接
- (void)disconnectDownloadSocket:(AsyncSocket *)sock {
    [self downloadComplete:_resultData];
    [sock disconnect];
    _resultData = nil;
    _totalLen = 0;
    _udpSocket = nil;
    [_udpArray removeAllObjects];
    [_tcpArray removeAllObjects];
}

//MARK:- 解析文件
- (void)downloadComplete:(NSData *)totalData {
    [[WBFileManager sharedInstance] saveXMLFile:totalData];
    [[WBParse sharedInstance] parseWithData:totalData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////                     ///////////////////////////////////////////////
////////////////////////////////    UDP BroadCast    ///////////////////////////////////////////////
////////////////////////////////                     ///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updSendOrder:(NSString *)orderString machineName:(NSString *)name {
    [self updSendOrder:orderString machineName:name isGroupCommand:false];
}

//发送普通指令和复合指令
- (void)updSendOrder:(NSString *)orderString machineName:(NSString *)name isGroupCommand:(BOOL)group {

    if (name.length == 0) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@设备名称为空",name]];
        return;
    }
    NSString * ipAddress = _machineDic[name];
    [self.commandStateDic setObject:@(group) forKey:[self commandStatedicKey:ipAddress name:orderString]];
    if (![_machineDic.allKeys containsObject:name]) {
        return;
    }
    if (ipAddress.length == 0) {
        NSLog(@"%@ 中控机地址为空",name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@设备IP地址为空",name]];
        return;
    }

    if (orderString.length == 0) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@设备指令为空",name]];
        return;
    }

    [self.cmdDic setObject:@([orderString integerValue]) forKey:ipAddress];

    NSError * error = nil;
    AsyncSocket * messageSocket = [[AsyncSocket alloc] initWithDelegate:self];
    [messageSocket connectToHost:ipAddress onPort:KUdpMessagePort error:&error];
    [_tcpArray addObject:messageSocket];

    if (error) {
        NSLog(@"TCP connect fail");
//        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@  发送指令的TCP连接失败",error.localizedDescription]];
    }
}

//发送重复指令
- (void)sendSessionCommand:(NSString *)orderString machineName:(NSString *)name {
    if (name.length == 0) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@设备名称为空",name]];
        return;
    }
    NSString * ipAddress = _machineDic[name];
    [self.commandStateDic setObject:@(false) forKey:[self commandStatedicKey:ipAddress name:orderString]];
    if (![_machineDic.allKeys containsObject:name]) {
        return;
    }
    if (ipAddress.length == 0) {
        NSLog(@"%@ 中控机地址为空",name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@设备IP地址为空",name]];
        return;
    }

    if (orderString.length == 0) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@设备指令为空",name]];
        return;
    }
    NSError * error = nil;
    AsyncSocket * messageSocket = [[AsyncSocket alloc] initWithDelegate:self];
    [messageSocket connectToHost:ipAddress onPort:KUdpMessagePort error:&error];
    [_tcpArray addObject:messageSocket];

    if (error) {
        NSLog(@"TCP connect fail");
//        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@  发送指令的TCP连接失败",error.localizedDescription]];
    }
}

- (void)sendCommand:(NSString *)host socked:(AsyncSocket *)sock {
    int32_t cmd = [[self.cmdDic objectForKey:host] intValue];
    BOOL isGroup = [[self.commandStateDic objectForKey:[self commandStatedicKey:host name:[self.cmdDic objectForKey:host]]] boolValue];
    WBJustAction * action = [[WBJustAction alloc] initWithCmd:cmd isGroup:isGroup];
    NSData * actionData = [action getData];
    [sock writeData:actionData withTimeout:-1 tag:KTcpSendCommandTag];
    [_tcpArray addObject:sock];
}

/**
 发现网络中的其他中控机
 */
- (void)scanOther {

    WBJustRequest * request = [[WBJustRequest alloc] initWithType:0x0];
    NSData * sockedData = [request getData];
    if (_broadUdpSocket) {
        [_broadUdpSocket close];
        _broadUdpSocket = nil;
    }
    if (!_broadUdpSocket) {
        _broadUdpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        NSError * error = nil;
        NSError * bindError = nil;
        BOOL success = [_broadUdpSocket bindToPort:KBoardPort error:&bindError];
        if (!success) {
            NSLog(@"绑定失败 ： %@",error);
        }
        [_broadUdpSocket enableBroadcast:true error:&error];
        if (error) {
            NSLog(@"_broadUdpSocket  开启广播失败");
        }
    }
    [_broadUdpSocket sendData:sockedData toHost:KBoardAddress port:KBoardPort withTimeout:-1 tag:KUdpBroadTag];
}

- (NSString *)commandStatedicKey:(NSString *)address name:(NSString *)orderName {
    return [NSString stringWithFormat:@"%@_%@",address,orderName];
}

- (void)repeatMessageSendFinish {
    for (AsyncSocket * sock in self.sessionSockets) {
        [sock disconnect];
    }
    [self.sessionSockets removeAllObjects];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {

//    [self sendCommand:host gcdSocked:sock];
//    [sock readDataWithTimeout:-1 tag:1000];
//    [self.sessionSockets addObject:sock];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    [_tcpArray addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:KTcpReceiveTag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (tag == KTcpReceiveTag) {
            NSLog(@"接收到XML数据  %lu",(unsigned long)data.length);
            if (_resultData) {
//                [SVProgressHUD showProgress:(CGFloat)_resultData.length / (CGFloat)_totalLen];
                [_resultData appendData:data];
            }
            if (!_resultData) {
                _resultData = [NSMutableData data];
                NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                _totalLen = [jsonDic[@"len"] longLongValue];
                NSString * downLoad = @"start download";
                [sock writeData:[downLoad dataUsingEncoding:NSUTF8StringEncoding] withTimeout:10 tag:KTcpReceiveTag];
            }
            [_tcpArray addObject:sock];
            if ( _resultData.length >= _totalLen && _totalLen != 0) {
                [self disconnectDownloadSocket:nil];
            };
            [sock readDataWithTimeout:10 tag:KTcpReceiveTag];
        }
    });
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {

}

- (void)sendCommand:(NSString *)host gcdSocked:(GCDAsyncSocket *)gcdSock {


}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
//    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"socket断开链接 error : %@",err.localizedDescription]];
}


#pragma KNoticationHandle 
- (void)parseError:(NSNotification *)noti {

}

#pragma mark - get 

- (NSMutableDictionary *)cmdDic {

    if (!_cmdDic) {
        _cmdDic = [[NSMutableDictionary alloc] init];
    }
    return _cmdDic;
}

- (NSMutableDictionary *)commandStateDic {
    if (!_commandStateDic) {
        _commandStateDic = [NSMutableDictionary dictionary];
    }
    return _commandStateDic;
}

- (NSMutableArray *)sessionSockets {

    if (!_sessionSockets) {
        _sessionSockets = [NSMutableArray array];
    }
    return _sessionSockets;
}

- (NSMutableArray *)commandBroadArr {

    if (!_commandBroadArr) {
        _commandBroadArr = [NSMutableArray array];
    }
    return _commandBroadArr;
}
@end
