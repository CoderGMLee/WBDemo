//
//  WBFileManager.h
//  WBDemo
//
//  Created by GM on 2017/3/31.
//  Copyright © 2017年 GM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBFileManager : NSObject

+ (WBFileManager *)sharedInstance;

- (BOOL)hasXMLFile;
- (void)saveXMLFile:(NSData *)data;
- (NSData *)getXMLFile;
- (void)clear;
@end
