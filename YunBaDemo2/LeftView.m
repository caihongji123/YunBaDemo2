//
//  LeftView.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/16.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "LeftView.h"
#import "GlobalAttribute.h"

#define COVER_VIEW_TAG 10
#define LEFT_VIEW_WITH_RATE 3/4

@interface LeftView ()
@end

@implementation LeftView

-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, 64)];
    CGContextAddPath(ctx, path.CGPath);
    UIColor *bgColor = self.backgroundColor;
    CGFloat h,s,b,a;
    [bgColor getHue:&h saturation:&s brightness:&b alpha:&a];
    UIColor *deepColor = [UIColor colorWithHue:h saturation:s brightness:b - 0.05f alpha:a];
    CGContextSetFillColorWithColor(ctx, deepColor.CGColor);
    CGContextFillPath(ctx);
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        CGRect frame;
        CGRect screen =[[UIScreen mainScreen] bounds];
        frame.size.width = screen.size.width * LEFT_VIEW_WITH_RATE;
        frame.size.height = screen.size.height ;
        frame.origin.x = - frame.size.width;
        frame.origin.y = 0;
        self.frame = frame;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, 0, screen.size.width * LEFT_VIEW_WITH_RATE, 64);
        [label setFont:[UIFont fontWithName:TEXT_FONT_BOLD size:20]];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"Topics and Aliases";
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
    }
    return self;
}

#pragma mark - public
-(void)setGestureView:(UIView *)gestureView {
    UIScreenEdgePanGestureRecognizer *r = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    r.edges = UIRectEdgeLeft;
    [gestureView addGestureRecognizer:r];
    _gestureView = gestureView;
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
}

-(void)setShaddow:(CGFloat)opacity {
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = 4;
    self.layer.shadowOffset = CGSizeMake(4, 4);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
}
-(void)showLeftView {
    if ([self.delegate respondsToSelector:@selector(leftViewMoveBegin:)]) {
        [self.delegate leftViewMoveBegin:self];
    }
    [self addCover:COVER_VIEW_TAG tapAction:@selector(tap:)];
    [self showAnimation:0.2];
}
-(void)hideLeftView:(void(^)(void))complete {
    [self hideAnimation:0.2 complete:complete];
}

#pragma mark - private
-(void)pan:(UIScreenEdgePanGestureRecognizer *)reco {
    static float lastPercentInView;
    CGPoint point = [reco translationInView:self.gestureView];
    CGFloat currentPercentInView;
    if (reco.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(leftViewMoveBegin:)]) {
            [self.delegate leftViewMoveBegin:self];
        }
        currentPercentInView = point.x / self.gestureView.frame.size.width;
        lastPercentInView = currentPercentInView;
        self.gestureView.userInteractionEnabled = NO;
        [self setShaddow:0];
        [self addCover:COVER_VIEW_TAG tapAction:@selector(tap:)];
    }else if (reco.state == UIGestureRecognizerStateChanged) {
        currentPercentInView =point.x / self.gestureView.frame.size.width;
        CGRect frame = self.frame;
        CGRect gFrame = self.gestureView.frame;
        UIView *coverView = [self.gestureView viewWithTag:COVER_VIEW_TAG];
        CGFloat offset = frame.size.width * (currentPercentInView - lastPercentInView);
        // leftView and mainView's movement
        frame.origin.x += offset;
        gFrame.origin.x += offset * 0.5f;
        self.frame = frame;
        self.gestureView.frame = gFrame;
        // coverView's alpha changing
        coverView.alpha = 1.0f * currentPercentInView * 0.9f;
        // leftView's shaddow changing
        [self setShaddow:0.4f * currentPercentInView];
        lastPercentInView = currentPercentInView;
    }else if (reco.state == UIGestureRecognizerStateEnded ) {
        CGRect screen =[[UIScreen mainScreen] bounds];
        if (self.frame.origin.x + self.frame.size.width < screen.size.width / 4) {
            [self hideAnimation:0.2 complete:nil];
        }else {
            [self showAnimation:0.2];
        }
        self.gestureView.userInteractionEnabled = YES;
    }else if (reco.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"cancelled");
    }
}

-(void)hideAnimation:(NSTimeInterval)interval complete:(void(^)(void))complete {
    [UIView animateWithDuration:interval delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.frame;
        CGRect gFrame = self.gestureView.frame;
        CGRect screen =[[UIScreen mainScreen] bounds];
        UIView *coverView = [self.gestureView viewWithTag:COVER_VIEW_TAG];
        frame.origin.x = - screen.size.width * LEFT_VIEW_WITH_RATE;
        gFrame.origin.x = 0;
        self.frame = frame;
        self.gestureView.frame = gFrame;
        coverView.alpha = 0;
        self.layer.shadowOpacity = 0;
    } completion:^(BOOL finished) {
        [self rmCover:COVER_VIEW_TAG];
        if ([self.delegate respondsToSelector:@selector(leftView:isShow:)]) {
            [self.delegate leftView:self isShow:NO];
        }
        if (complete) {complete();}
    }];
}

-(void)showAnimation:(NSTimeInterval)interval {
    [UIView animateWithDuration:interval delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.frame;
        CGRect gFrame = self.gestureView.frame;
        frame.origin.x = 0;
        gFrame.origin.x = frame.size.width * 0.5f;
        self.frame = frame;
        self.gestureView.frame = gFrame;
        [self setShaddow:0.4f];
        UIView *coverView = [self.gestureView viewWithTag:COVER_VIEW_TAG];
        coverView.alpha = 0.6f;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(leftView:isShow:)]) {
            [self.delegate leftView:self isShow:YES];
        }
    }];
}

-(void)tap:(id)sender {
    [self hideAnimation:0.2 complete:nil];
}

-(UIView *)addCover:(NSInteger)tag tapAction:(SEL)tapAction {
    UIView *sv = [[UIView alloc] init];
    sv.frame = self.gestureView.bounds;
    sv.tag = tag;
    sv.backgroundColor = [UIColor whiteColor];
    sv.alpha = 0;
    if (tapAction) {
        [sv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:tapAction]];
    }
    [self.gestureView addSubview:sv];
    [self.gestureView bringSubviewToFront:sv];
    return sv;
}
-(void)rmCover:(NSInteger)tag {
    UIView *sv = [self.gestureView viewWithTag:tag];
    [sv removeFromSuperview];
}


@end
