//
//  GCDTimer.h
//  GCDTimer
//
//  Created by GM on 16/7/25.
//  Copyright © 2016年 LGM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMTimer : NSObject
{
    NSMutableDictionary * _timerContainer;
    NSMutableDictionary * _countDownResidueTimes;
}

+ (DMTimer *)sharedInstance;
- (void)clear;
- (void)scheduleDispatchTimerName:(NSString *)timerName timeInterval:(double)interval queue:(dispatch_queue_t)queue repeats:(BOOL)repeats action:(dispatch_block_t)action;

//倒计时
- (void)countDownTimerName:(NSString *)timerName timerInterVal:(double)interval queue:(dispatch_queue_t)queue maxTime:(long long)maxTime minusBy:(long long)unitTime action:(dispatch_block_t)action;

/**
 获取倒计时的剩余时间
 */
- (long long)residueTimeForTimer:(NSString *)timerName;

- (void)cancelTimerWithName:(NSString *)timerName;

@end
