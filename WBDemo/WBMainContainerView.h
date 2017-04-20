//
//  WBMainContainerView.h
//  WBDemo
//
//  Created by GM on 17/3/12.
//  Copyright © 2017年 GM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WBMainViewDelegate <NSObject>

- (void)backButtonClick;

@end

@interface WBMainContainerView : UIView <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, weak) id<WBMainViewDelegate> delegate;

@end
