//
//  WBModelManager.m
//  WBDemo
//
//  Created by GM on 17/3/7.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBModelManager.h"

@interface WBModelManager ()

@property (nonatomic, strong) NSMutableArray * modelArray;
@property (nonatomic, strong) NSMutableArray * controllerModelArray;

@end

@implementation WBModelManager

+ (WBModelManager *)sharedInstance {

    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[WBModelManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _modelArray = [NSMutableArray array];
        _controllerModelArray = [NSMutableArray array];
    }
    return self;
}

- (void)addControllerModel:(WBControlModel *)model {
    [_controllerModelArray addObject:model];
}


- (WBControlModel *)controlModelAtIndex:(NSInteger)index {
    if (index >= _controllerModelArray.count) {
        NSLog(@"数组越界  index = %ld",(long)index);
        return nil;
    }
    return _controllerModelArray[index];
}

- (void)clearAll {
    [_modelArray removeAllObjects];
    [_controllerModelArray removeAllObjects];
}


@end
