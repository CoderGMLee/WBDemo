//
//  GCDTimer.m
//  GCDTimer
//
//  Created by GM on 16/7/25.
//  Copyright © 2016年 LGM. All rights reserved.
//

#import "DMTimer.h"

@implementation DMTimer

+ (DMTimer *)sharedInstance{

    static DMTimer * timer = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        timer = [[DMTimer alloc]init];
    });
    return timer;
}

- (instancetype)init{
    if (self = [super init]) {
        _timerContainer = [NSMutableDictionary dictionary];
        _countDownResidueTimes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)scheduleDispatchTimerName:(NSString *)timerName timeInterval:(double)interval queue:(dispatch_queue_t)queue repeats:(BOOL)repeats action:(dispatch_block_t)action{

    if (timerName == nil || timerName.length == 0) {
        return;
    }
    //queue
    if (queue == nil) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    //source
    dispatch_source_t timer = [_timerContainer objectForKey:timerName];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_resume(timer);
        [_timerContainer setObject:timer forKey:timerName];
    }
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);

    __weak typeof(self) wself = self;
    //event
    dispatch_source_set_event_handler(timer, ^{
        action();
        if (!repeats) {
            [wself cancelTimerWithName:timerName];
        }
    });
}

- (void)countDownTimerName:(NSString *)timerName timerInterVal:(double)interval queue:(dispatch_queue_t)queue maxTime:(long long)maxTime minusBy:(long long)unitTime action:(dispatch_block_t)action {
    if (maxTime == 0 || unitTime == 0) {
        return;
    }
    [_countDownResidueTimes setObject:@(maxTime) forKey:timerName];
    [self scheduleDispatchTimerName:timerName timeInterval:interval queue:queue repeats:true action:^{
        long long residueTime = [[_countDownResidueTimes objectForKey:timerName] longLongValue];
        residueTime -= unitTime;
        if (residueTime <= 0) {
            residueTime = 0;
        }
        [_countDownResidueTimes setObject:@(residueTime) forKey:timerName];
        action();
    }];
}

- (long long)residueTimeForTimer:(NSString *)timerName {
    double residueTime = [[_countDownResidueTimes objectForKey:timerName] doubleValue];
    return residueTime;
}

- (void)cancelTimerWithName:(NSString *)timerName{
    dispatch_source_t timer = [_timerContainer objectForKey:timerName];
    if (!timerName || !timer) {
        return;
    }
    [_timerContainer removeObjectForKey:timerName];
    dispatch_source_cancel(timer);
}
- (void)clear{
    if (_timerContainer) {
        [_timerContainer removeAllObjects];
    }
}

@end
