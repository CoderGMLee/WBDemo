//
//  WBDemoTests.m
//  WBDemoTests
//
//  Created by GM on 17/2/16.
//  Copyright © 2017年 GM. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WBCheckIp.h"
#import "WBParse.h"
@interface WBDemoTests : XCTestCase

@end

@implementation WBDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

//    NSString * ipAddress = [WBCheckIp getIPAddress:true];
//    NSString * pubIPAddress = [WBCheckIp getPublicIPAddress];
//    NSLog(@"%@", [NSString stringWithFormat:@"IP: %@,  pubIP:  %@",ipAddress,pubIPAddress]);


    [WBParse test];



}

- (void)testPerformanceExample {
    // This is an example of a performance test case.

    [WBParse test];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
