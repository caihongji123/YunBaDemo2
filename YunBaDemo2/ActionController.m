//
//  ActionController.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/20.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionController.h"
#import "GlobalAttribute.h"

@interface ActionView : UIView
@property (nonatomic, strong) NSArray                       * buttonArray;
@property (nonatomic, strong) UIView                        * cardView;
@property (nonatomic)         id<ActionControllerDelegate>    delegate;
@property (nonatomic)         id                              obj;
-(instancetype)initWithTitles:(NSArray<NSString *> *)titles location:(CGPoint)location target:(id<ActionControllerDelegate>)target userObj:(id)obj;
-(void)animateWithView;
@end

@implementation ActionView
-(instancetype)initWithTitles:(NSArray<NSString *> *)titles location:(CGPoint)location target:(id<ActionControllerDelegate>)target userObj:(id)obj{
    if (self = [super init]) {
        self.delegate = target;
        self.obj = obj;
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        UIView *bottomView = [[UIView alloc] init];
        CGFloat maxWidth = 0;
        CGFloat sumOfHeight = 16;
        for (NSString *title in titles) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setTitle:title forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:TEXT_FONT_BOLD size:17];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button sizeToFit];
            if (button.frame.size.width > maxWidth)
            {maxWidth = button.frame.size.width + 8;}
            sumOfHeight += button.frame.size.height;
            [buttons addObject:button];
        }
        bottomView.frame = CGRectMake(0, 0, maxWidth, sumOfHeight + ((buttons.count - 1)*2) );
        CGFloat y = 0 ; int tag = 0;
        for (UIButton *button in buttons) {
            button.frame = CGRectMake(4, 8 + y,
                                      button.frame.size.width,
                                      button.frame.size.height);
            button.tag = tag;
            [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
            [bottomView addSubview:button];
            y += button.frame.size.height + 2;
            tag++;
        }
        _buttonArray = [buttons copy];
        CGFloat h,s,b,a;
        [STYLE_COLOR getHue:&h saturation:&s brightness:&b alpha:&a];
        bottomView.backgroundColor = [UIColor colorWithHue:h saturation:s brightness:b * 1.3 alpha:a];
        bottomView.layer.shadowOffset = CGSizeMake(0, 3);
        bottomView.layer.cornerRadius = 8.0f;
        bottomView.layer.shadowOpacity = 0.5f;
        [self addToSelf:bottomView location:location];
    }
    return self;
}
-(void)addToSelf:(UIView *)view location:(CGPoint)location{
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, 0, size.width, size.height);
    self.backgroundColor = [UIColor clearColor];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    if (location.x + view.frame.size.width > size.width) {
        location.x = size.width - view.frame.size.width;
    }
    if (location.y + view.frame.size.height > size.height) {
        location.y = size.height - view.frame.size.height;
    }
    view.frame = CGRectMake(location.x, location.y, view.frame.size.width, view.frame.size.height);
    [self addSubview:view];
    self.cardView = view;
}
-(void)animateWithView {
    self.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    [UIView animateWithDuration:0.5f delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            self.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
                        } completion:^(BOOL finished) {
                            
                        }];
}
-(void)tap:(id)sender {
    self.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    [UIView animateWithDuration:0.2f delay:0
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            self.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
                            self.cardView.alpha = 0;
                            if ([self.delegate respondsToSelector:@selector(actionControlDidFinished:isCancel:)]) {
                                [self.delegate actionControlDidFinished:self.obj isCancel:sender ? YES : NO];
                            }
                        } completion:^(BOOL finished) {
                            [self removeFromSuperview];
                        }];
}
-(void)action:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(actionControlDidAct:)]) {
        [self.delegate actionControlDidAct:button.tag];
        [self tap:nil];
    }
}
@end

@implementation ActionController
+(void)beginActionControlWithTarget:(id<ActionControllerDelegate>)target Titles:(NSArray<NSString *> *)titles location:(CGPoint)location userObj:(id)obj {
    ActionView *actionView = [[ActionView alloc] initWithTitles:titles location:location target:target userObj:obj];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:actionView];
    [window bringSubviewToFront:actionView];
    [actionView animateWithView];
}
@end
