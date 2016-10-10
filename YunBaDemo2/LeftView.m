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
#define ANIMATE_DURATION 0.4

@interface LeftView ()
@property (nonatomic) CGFloat           viewRate;
@property (nonatomic) CGFloat           originX;
@end

@implementation LeftView
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        CGRect frame;
        CGRect screen =[[UIScreen mainScreen] bounds];
        frame.size.width = screen.size.width * 3/4.0;
        frame.size.height = screen.size.height ;
        frame.origin.x = - frame.size.width; // _originX
        frame.origin.y = 0;
        self.frame = frame;
    }
    return self;
}

#pragma mark - public
-(void)setGestureView:(UIView *)gestureView withType:(LeftViewType)type viewRate:(CGFloat)viewRate {
    _type = type;
    _viewRate = viewRate;
    _gestureView = gestureView;
    UIRectEdge edge;
    CGRect frame = self.frame;
    CGRect screen =[[UIScreen mainScreen] bounds];
    switch (type) {
        case LeftViewTypeLeft:
            _originX = - frame.size.width;
            edge = UIRectEdgeLeft;
            break;
        case LeftViewTypeRight:
            _originX = screen.size.width;
            edge = UIRectEdgeRight;
            break;
        default:break;
    }
    frame.size.width = screen.size.width * _viewRate;
    frame.origin.x = _originX;
    self.frame = frame;
    
    
    UIScreenEdgePanGestureRecognizer *r = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    r.edges = edge;
    [gestureView addGestureRecognizer:r];
    [[[UIApplication sharedApplication].delegate window] addSubview:self];

    
}

-(void)setShaddow:(CGFloat)opacity {
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = 4;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
}
-(void)showLeftView {
    if ([self.delegate respondsToSelector:@selector(leftViewMoveBegin:)]) {
        [self.delegate leftViewMoveBegin:self];
    }
    [self addCover:COVER_VIEW_TAG tapAction:@selector(tap:)];
    [self showAnimation:ANIMATE_DURATION];
}
-(void)hideLeftView:(void(^)(void))complete {
    [self hideAnimation:ANIMATE_DURATION complete:complete];
}

#pragma mark - private
-(void)pan:(UIPanGestureRecognizer *)reco {
    static float lastPercentInView;
    CGPoint point = [reco translationInView:self.gestureView];
    CGFloat currentPercentInView;
    BOOL isOpen = [reco isKindOfClass:[UIScreenEdgePanGestureRecognizer class]] ? YES : NO;
    if (reco.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(leftViewMoveBegin:)]) {
            [self.delegate leftViewMoveBegin:self];
        }
        currentPercentInView = point.x / self.gestureView.frame.size.width;
        lastPercentInView = currentPercentInView;
        self.gestureView.userInteractionEnabled = NO;
        [self setShaddow:isOpen ? 0 : 0.4f];
        if (isOpen) {[self addCover:COVER_VIEW_TAG tapAction:@selector(tap:)];}
    }else if (reco.state == UIGestureRecognizerStateChanged) {
        currentPercentInView =point.x / self.gestureView.frame.size.width;
        CGRect frame = self.frame;
        CGRect gFrame = self.gestureView.frame;
        UIView *coverView = [self.gestureView viewWithTag:COVER_VIEW_TAG];
        CGFloat offset = frame.size.width * (currentPercentInView - lastPercentInView);
        // leftView and mainView's movement
        frame.origin.x += offset;
        switch (self.type) {
            case LeftViewTypeLeft:
                if (!isOpen && frame.origin.x > _originX + frame.size.width) { return; }
                self.layer.shadowOffset = CGSizeMake(4, 0);
                //gFrame.origin.x += (offset * 0.5f);
                break;
            case LeftViewTypeRight:
                if (!isOpen && frame.origin.x < _originX - frame.size.width) { return; }
                self.layer.shadowOffset = CGSizeMake(-4, 0); break;
        default:break; }
        gFrame.origin.x += (offset * 0.5f);
        gFrame.origin.x = [NSString stringWithFormat:@"%.0f", gFrame.origin.x].floatValue;
        self.frame = frame;
        self.gestureView.frame = gFrame;
        //NSLog(@"%f",self.gestureView.frame.origin.x);
        CGFloat realPercentInView = (isOpen ? fabs(currentPercentInView) : 1-fabs(currentPercentInView));
        // coverView's alpha changing
        coverView.alpha = 1.0f * realPercentInView * 0.9f;
        // leftView's shaddow changing
        [self setShaddow:0.4f * realPercentInView];
        lastPercentInView = currentPercentInView;
    }else if (reco.state == UIGestureRecognizerStateEnded ) {
        CGRect screen =[[UIScreen mainScreen] bounds];
        CGFloat x,openRate,closeRate;
        switch (self.type) {
            case LeftViewTypeLeft:
                x = self.frame.origin.x + self.frame.size.width;
                openRate = 4; closeRate = 2;break;
            case LeftViewTypeRight:
                x = -self.frame.origin.x;
                openRate = - 4/3;;closeRate = - 2;break;
            default:break;
        }
        if (x < screen.size.width / (isOpen ? openRate : closeRate)) {
            [self hideAnimation:ANIMATE_DURATION complete:nil];
        }else {
            [self showAnimation:ANIMATE_DURATION];
        }
        self.gestureView.userInteractionEnabled = YES;
        
    }else if (reco.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"cancelled");
    }
}

-(void)hideAnimation:(NSTimeInterval)interval complete:(void(^)(void))complete {
    [UIView animateWithDuration:interval delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.frame;
        CGRect gFrame = self.gestureView.frame;
        UIView *coverView = [self.gestureView viewWithTag:COVER_VIEW_TAG];
        frame.origin.x = self.originX;
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
    [UIView animateWithDuration:interval delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.frame;
        CGRect gFrame = self.gestureView.frame;
        switch (self.type) {
            case LeftViewTypeLeft:
                frame.origin.x = _originX + frame.size.width;
                gFrame.origin.x = frame.size.width * 0.5f;
                break;
            case LeftViewTypeRight:
                frame.origin.x = _originX - frame.size.width;
                gFrame.origin.x = -frame.size.width * 0.5f;
                break;
            default:break;
        }
        self.frame = frame;
        self.gestureView.frame = gFrame;
        [self setShaddow:0.4f];
        UIView *coverView = [self.gestureView viewWithTag:COVER_VIEW_TAG];
        coverView.alpha = 0.88f;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(leftView:isShow:)]) {
            [self.delegate leftView:self isShow:YES];
        }
    }];
}

-(void)tap:(id)sender {
    [self hideAnimation:ANIMATE_DURATION complete:nil];
}

-(UIView *)addCover:(NSInteger)tag tapAction:(SEL)tapAction {
    UIView *sv = [[UIView alloc] init];
    sv.frame = self.gestureView.bounds;
    sv.tag = tag;
    sv.backgroundColor = [UIColor whiteColor];
    sv.alpha = 0;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [sv addGestureRecognizer:pan];
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
