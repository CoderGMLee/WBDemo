//
//  WBMainContainerView.m
//  WBDemo
//
//  Created by GM on 17/3/12.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBMainContainerView.h"
#import "UIView+Frame.h"
#import "UIColor+DMExtension.h"
@implementation WBMainContainerView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configScrollView];
    [self addGradient];
    [self setPageControlCurrentPage];
    [self setTitleLabel];
}

- (void)addGradient {

    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = [UIScreen mainScreen].bounds;
    [self.layer insertSublayer:gradientLayer atIndex:0];
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1.00].CGColor, (__bridge id)[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00].CGColor];
    gradientLayer.startPoint = CGPointMake(0.5, 1);
    gradientLayer.endPoint = CGPointMake(0.5, 0);

}

- (void)configScrollView {

    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * 4, self.scrollView.height);

    for (NSInteger index = 1; index < 5; index ++) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.width * (index - 1), 0, self.scrollView.width, self.scrollView.height)];
        NSString * imageName = [NSString stringWithFormat:@"tip%ld_img",index];
        imageView.image = [UIImage imageNamed:imageName];
        [self.scrollView addSubview:imageView];
    }
}

- (IBAction)backAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(backButtonClick)]) {
        [_delegate backButtonClick];
    }
}
- (IBAction)leftPage:(id)sender {
    if (self.scrollView.contentOffset.x != 0) {
        CGPoint offSet = CGPointMake(self.scrollView.contentOffset.x - self.scrollView.width, self.scrollView.contentOffset.y);
        [UIView animateWithDuration:0.5 animations:^{
            self.scrollView.contentOffset = offSet;
        } completion:^(BOOL finished) {
            [self setPageControlCurrentPage];
            [self setTitleLabel];
        }];

    }
}
- (IBAction)rightPage:(id)sender {
    if (self.scrollView.contentOffset.x != self.scrollView.contentSize.width - self.scrollView.width) {
        CGPoint offSet = CGPointMake(self.scrollView.contentOffset.x + self.scrollView.width, self.scrollView.contentOffset.y);
        [UIView animateWithDuration:0.5 animations:^{
            self.scrollView.contentOffset = offSet;
        } completion:^(BOOL finished) {
            [self setPageControlCurrentPage];
            [self setTitleLabel];
        }];
    }
}

- (void)setPageControlCurrentPage {
    NSInteger currentPage = self.scrollView.contentOffset.x / self.scrollView.width;
    self.pageControl.currentPage = currentPage;
}

- (void)setTitleLabel {
    switch (self.pageControl.currentPage) {
        case 0:
        {
            self.titleLabel.text = @"步骤一：打开中控的界面设计软件，设计好界面";
        }
            break;
        case 1:
        {
            self.titleLabel.text = @"步骤二：以此打开文件，导出，手机端";
        }
            break;
        case 2:
        {
            self.titleLabel.text = @"步骤三：可见当前局域网中，进入下载模式的手机";
        }
            break;
        case 3:
        {
            self.titleLabel.text = @"步骤四：选择手机，按下上传按钮即可";
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setPageControlCurrentPage];
    [self setTitleLabel];
}

@end
