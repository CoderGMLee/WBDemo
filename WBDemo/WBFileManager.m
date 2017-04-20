//
//  WBFileManager.m
//  WBDemo
//
//  Created by GM on 2017/3/31.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBFileManager.h"
#import <SVProgressHUD.h>

#define KFileName @"XMLFileData"
@implementation WBFileManager

+ (WBFileManager *)sharedInstance {

    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[WBFileManager alloc] init];
    });
    return sharedInstance;
}

- (BOOL)hasXMLFile {
    
    NSString * path = [self XMLFilePath];
    NSData * data = [[NSData alloc] initWithContentsOfFile:[self XMLFilePath]];
    return [[NSFileManager defaultManager] fileExistsAtPath:path] && data.length != 0;
}

- (void)saveXMLFile:(NSData *)data {

    BOOL success = [[NSFileManager defaultManager] createFileAtPath:[self XMLFilePath] contents:data attributes:nil];
    if (!success) {
        [SVProgressHUD showInfoWithStatus:@"写入文件失败"];
    }
}


- (NSData *)getXMLFile {
    if (self.hasXMLFile) {
        NSData * XMLData = [[NSData alloc] initWithContentsOfFile:[self XMLFilePath]];
        return XMLData;
    } else {
        [SVProgressHUD showInfoWithStatus:@"文件不存在"];
    }
    return nil;
}

- (NSString *)XMLFilePath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordListPath = [documentPath stringByAppendingPathComponent:KFileName];
    return recordListPath;
}

- (void)clear {
    NSString * path = [self XMLFilePath];
    NSError * err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&err];
    if (err) {
        [SVProgressHUD showInfoWithStatus:err.localizedDescription];
    }
}
@end
