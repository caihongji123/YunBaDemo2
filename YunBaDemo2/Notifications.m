//
//  Notifications.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/19.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Notifications.h"
#import "GlobalAttribute.h"


@interface Notifications ()
+(void)animateWithView:(UIView *)view;
+(void)deleteViewWithAnimate:(UIView *)view up:(BOOL)up;
@end

@interface NotiView : UIView
@property (nonatomic,strong) UILabel *textLabel;
@property (nonatomic)        BOOL     isRemove;
@end

@implementation NotiView
-(instancetype)initWithText:(NSString *)text {
    if (self = [super init]) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        UIFont *font = [UIFont fontWithName:TEXT_FONT size:16];
        CGSize contentSize = [Notifications sizeFromCurrentWidth:screenSize.width - 32 text:text font:font];
        
        self.frame = CGRectMake(8, -(contentSize.height + 16 + 8), screenSize.width - 16, contentSize.height + 16);
        self.backgroundColor = STYLE_COLOR;
        self.layer.cornerRadius = 8.0f;
        self.layer.shadowOpacity = 0.4f;
        
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.numberOfLines = 0;
        self.textLabel.frame = CGRectMake(8, 8, screenSize.width - 32, contentSize.height);
        self.textLabel.text = text;
        [self.textLabel setFont:font];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textLabel];
        
        UISwipeGestureRecognizer *swipeU = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipeU.direction = UISwipeGestureRecognizerDirectionUp;
        UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipeR.direction = UISwipeGestureRecognizerDirectionRight;
        self.textLabel.userInteractionEnabled = YES;
        [self.textLabel addGestureRecognizer:swipeR];
        [self.textLabel addGestureRecognizer:swipeU];
    }
    return self;
}
-(void)swipe:(UISwipeGestureRecognizer *)sender {
    sender.direction == UISwipeGestureRecognizerDirectionUp ?
    ([Notifications deleteViewWithAnimate:self up:YES]):
    ([Notifications deleteViewWithAnimate:self up:NO]);
}
@end

@implementation Notifications
+(void)sendNotification:(NSString *)content {
    
    NotiView *notiView = [[NotiView alloc] initWithText:content];
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:notiView];
    [window bringSubviewToFront:notiView];
    
    [Notifications animateWithView:notiView];
    
}

+(void)animateWithView:(NotiView *)view {
    [UIView animateWithDuration:0.8f
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = view.frame;
                         frame.origin.y = 25;
                         view.frame = frame;
                         
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [Notifications deleteViewWithAnimate:view up:YES];
        });
    }];
}

+(void)deleteViewWithAnimate:(NotiView *)view up:(BOOL)up{
    if (!view.isRemove) {
        view.isRemove = 1;
        [UIView animateWithDuration:0.5f animations:^{
            CGRect frame = view.frame;
            up ? (frame.origin.y = -(frame.size.height + 16 + 8)) :
            (frame.origin.x = frame.size.width + 16 + 8);
            view.frame = frame;
        }completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
}

+(CGSize)sizeFromCurrentWidth:(CGFloat)width text:(NSString *)text font:(UIFont *)font{
    CGSize size = CGSizeMake(width, 0);
    CGSize lableSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    return lableSize;
}
@end
