//
//  WBParse.h
//  WBDemo
//
//  Created by GM on 17/2/17.
//  Copyright © 2017年 GM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "WBTextViewModel.h"
#import "WBControlModel.h"
#import "WBButtonModel.h"
#import "WBImageViewModel.h"
#import "WBModelManager.h"

#define KNodeDOCUMENT_ELEMENT @"DOCUMENT_ELEMENT"
#define KNodeObject @"Object"
#define KNodeProperty @"Property"
#define KElementControl @"ZiUserControl"
#define KElementButton @"ZiButton"
#define KElementTextView @"ZiTextView"
#define KElementImageView @"ZiImageView"

@interface WBParse : NSObject

+ (WBParse *)sharedInstance;
+ (void)parse;
+ (void)parseWithData:(NSData *)data;


- (void)parse;
- (void)parseWithData:(NSData *)data;

@end
