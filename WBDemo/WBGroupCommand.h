//
//  WBGroupCommand.h
//  WBDemo
//
//  Created by GM on 2017/3/31.
//  Copyright © 2017年 GM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBGroupCommand : NSObject

+ (WBGroupCommand *)sharedInstance;

@property (nonatomic, copy) NSString * inChannel;
@property (nonatomic, copy) NSString * outChannel;
@property (nonatomic, copy) NSString * getMatrixtype;
@end
