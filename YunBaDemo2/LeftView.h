//
//  LeftView.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/16.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeftViewDelegate;

@interface LeftView : UIView
@property (nonatomic) UIView * gestureView;
@property id<LeftViewDelegate> delegate;
-(void)showLeftView;
-(void)hideLeftView:(void(^)(void))complete;
@end

@protocol LeftViewDelegate <NSObject>

@optional
-(void)leftViewMoveBegin:(LeftView *)leftView;
-(void)leftView:(LeftView *)leftView isShow:(BOOL)show;
@end
