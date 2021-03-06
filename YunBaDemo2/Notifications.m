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
+(void)animateWithView:(UIView *)view complete:(void(^)(void))complete;
+(void)deleteViewWithAnimate:(UIView *)view up:(BOOL)up;
@end

@interface NotiView : UIView
@property (nonatomic,strong) UILabel *textLabel;
@property (nonatomic)        BOOL     isRemove;
@property (nonatomic)        BOOL     isTouch;
@end

@implementation NotiView
-(instancetype)initWithText:(NSString *)text {
    if (self = [super init]) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        UIFont *font = [UIFont fontWithName:TEXT_FONT size:16];
        CGSize contentSize = [Notifications sizeFromCurrentWidth:screenSize.width - 32 text:text font:font];
        
        self.frame = CGRectMake(8, -(contentSize.height + 16 + 8), screenSize.width - 16, contentSize.height + 32);
        self.backgroundColor = STYLE_COLOR;
        self.layer.cornerRadius = 8.0f;
        self.layer.shadowOpacity = 0.4f;
        
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.numberOfLines = 0;
        self.textLabel.frame = CGRectMake(8, 16, screenSize.width - 32, contentSize.height);
        self.textLabel.text = text;
        [self.textLabel setFont:font];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textLabel];
        
        UISwipeGestureRecognizer *swipeU = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipeU.direction = UISwipeGestureRecognizerDirectionUp;
        UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        swipeR.direction = UISwipeGestureRecognizerDirectionRight;
        self.textLabel.userInteractionEnabled = YES;
        //[self.textLabel addGestureRecognizer:swipeR];
        //[self.textLabel addGestureRecognizer:swipeU];
        [self.textLabel addGestureRecognizer:pan];
        _isTouch = NO;
    }
    return self;
}
-(void)pan:(UIPanGestureRecognizer *)sender {
    static float lastPercentInView;
    UIWindow *win = [[UIApplication sharedApplication].delegate window];
    CGPoint point = [sender translationInView:win];
    CGFloat currentPercentInView;
    if (sender.state == UIGestureRecognizerStateBegan) {
        currentPercentInView = point.y / win.frame.size.width;
        lastPercentInView = currentPercentInView;
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        currentPercentInView =point.y / win.frame.size.width;
        CGRect frame = self.frame;
        CGFloat offset = frame.size.height * (currentPercentInView - lastPercentInView);
        frame.origin.y += offset;
        self.frame = frame;
        lastPercentInView = currentPercentInView;
    }else if (sender.state == UIGestureRecognizerStateEnded ) {
        [Notifications deleteViewWithAnimate:self up:YES];
    }
}
-(void)swipe:(UISwipeGestureRecognizer *)sender {
    sender.direction == UISwipeGestureRecognizerDirectionUp ?
    ([Notifications deleteViewWithAnimate:self up:YES]):
    ([Notifications deleteViewWithAnimate:self up:NO]);
}
@end
static NotiView * showingView;
static NSMutableArray <NotiView *> * notiQueue;
static dispatch_semaphore_t semaphore;
@implementation Notifications
+(void)sendNotification:(NSString *)content {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        semaphore = dispatch_semaphore_create(1);
        notiQueue = [NSMutableArray new];
        dispatch_queue_t queue = dispatch_queue_create("com.yunba.ios.notificationQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            for (;;) {
                sleep(1);
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                if (notiQueue.count == 0) { dispatch_semaphore_signal(semaphore); continue; }
                dispatch_async(dispatch_get_main_queue(), ^{
                    NotiView *notiView;
                    if (notiQueue.count >= 5) {
                        notiView = [[NotiView alloc] initWithText:[NSString stringWithFormat:@"%lu new notifications",notiQueue.count]];
                        [notiQueue removeAllObjects];
                    }else {
                        notiView = [notiQueue lastObject];
                        [notiQueue removeObject:notiView];
                    }
                    UIWindow *window = [[UIApplication sharedApplication].delegate window];
                    [window addSubview:notiView];
                    [window bringSubviewToFront:notiView];
                    [Notifications animateWithView:notiView complete:^{
                        if (showingView) {showingView.isTouch = YES; [showingView removeFromSuperview];}
                        showingView = notiView;
                        dispatch_semaphore_signal(semaphore);
                    }];
                });
            }
        });
    });
    NotiView *notiView = [[NotiView alloc] initWithText:content];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [notiQueue addObject:notiView];
        dispatch_semaphore_signal(semaphore);
    });
    
}
+(void)animateWithView:(NotiView *)view complete:(void(^)(void))complete {
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
        if (complete) { complete(); }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!view.isTouch) {
                [Notifications deleteViewWithAnimate:view up:YES];
            }
        });
    }];
}
+(void)deleteViewWithAnimate:(NotiView *)view up:(BOOL)up {
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
+(CGSize)sizeFromCurrentWidth:(CGFloat)width text:(NSString *)text font:(UIFont *)font {
    CGSize size = CGSizeMake(width, 0);
    CGSize lableSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    return lableSize;
}
+(CGSize)sizeFromCurrentHeight:(CGFloat)height text:(NSString *)text font:(UIFont *)font {
    CGSize size = CGSizeMake(0, height);
    CGSize lableSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    return lableSize;
}
@end
