//
//  ActionView.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/27.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "ActionView.h"
#import "GlobalAttribute.h"
#import "ActionController.h"


@implementation ActionCardView
-(instancetype)initWithTitles:(NSArray<NSString *> *)titles location:(CGPoint)location target:(id<ActionControllerDelegate>)target userObj:(id)obj identifier:(NSString *)identifier{
    if (self = [super init]) {
        _delegate = target;
        _obj = obj;
        _identifier = identifier;
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
                            if ([self.delegate respondsToSelector:@selector(actionControlDidFinished:isCancel:identifier:)]) {
                                [self.delegate actionControlDidFinished:self.obj isCancel:sender ? YES : NO identifier:self.identifier];
                            }
                        } completion:^(BOOL finished) {
                            [self removeFromSuperview];
                        }];
}
-(void)action:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(actionControlDidAct:identifier:)]) {
        [self.delegate actionControlDidAct:button.tag identifier:self.identifier];
        [self tap:nil];
    }
}
@end

#define ACTIONVIEW_TABLEVIEW_HEIGHT 30
@implementation ActionTableView
-(instancetype)initWithTitles:(NSArray<NSString *> *)titles location:(CGPoint)location target:(id<ActionControllerDelegate>)target userObj:(id)obj identifier:(NSString *)identifier {
    if (self = [super init]) {
        _delegate = target;
        _titlesArray = titles;
        _obj = obj;
        _identifier = identifier;
        UITableView *tableView = [[UITableView alloc] init];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self; tableView.dataSource = self;
        CGFloat height = _titlesArray.count < 4 ? _titlesArray.count * ACTIONVIEW_TABLEVIEW_HEIGHT : 4 * ACTIONVIEW_TABLEVIEW_HEIGHT;
        tableView.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width - 8, height);
        tableView.layer.cornerRadius = 6.0f;
        tableView.backgroundColor = STYLE_COLOR;
        [self addToSelf:tableView location:location];
        
    }
    return self;
}
-(void)addToSelf:(UITableView *)view location:(CGPoint)location{
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, 0, size.width, size.height);
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    location.x = location.x - view.frame.size.width / 2;
    location.y = location.y - view.frame.size.height;
    if (location.x < 0) {location.x = 0;}
    if (location.y < 0) {location.y = 0;}
    view.frame = CGRectMake(location.x, location.y, view.frame.size.width, view.frame.size.height);
    [self addSubview:view];
    [self bringSubviewToFront:view];
    self.tableView = view;
}
-(void)animateWithView {
    self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    [UIView animateWithDuration:0.5f delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
                        } completion:^(BOOL finished) {
                            
                        }];
}
-(void)close {
    [self tap:nil];
}
-(void)tap:(id)sender {
    self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    [UIView animateWithDuration:0.2f delay:0
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
                            self.tableView.alpha = 0;
                            if ([self.delegate respondsToSelector:@selector(actionControlDidFinished:isCancel:identifier:)]) {
                                [self.delegate actionControlDidFinished:self.obj isCancel:sender ? YES : NO identifier:self.identifier];
                            }
                        } completion:^(BOOL finished) {
                            [self removeFromSuperview];
                        }];
}
// 解决手势冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqual:@"UITableViewCellContentView"])
    {return NO;}  return YES;
}
#pragma mark - tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {return 1;}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titlesArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ACTIONVIEW_TABLEVIEW_HEIGHT;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] init];
    label.text = self.titlesArray[indexPath.row];
    label.font = [UIFont fontWithName:TEXT_FONT size:17];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.frame = CGRectMake(8, (ACTIONVIEW_TABLEVIEW_HEIGHT - label.frame.size.height) / 2, label.frame.size.width, label.frame.size.height);
    [cell.contentView addSubview:label];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(actionControlDidAct:identifier:)]) {
        [self.delegate actionControlDidAct:indexPath.row identifier:self.identifier];
    }
    [self tap:nil];
}
@end
