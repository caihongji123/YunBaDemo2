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

@implementation ActionController
+(void)beginActionCardControlWithTarget:(id<ActionControllerDelegate>)target Titles:(NSArray<NSString *> *)titles location:(CGPoint)location userObj:(id)obj identifier:(NSString *)identifier{
    ActionCardView *actionView = [[ActionCardView alloc] initWithTitles:titles location:location target:target userObj:obj identifier:identifier];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:actionView];
    [window bringSubviewToFront:actionView];
    [actionView animateWithView];
}
+ (ActionTableView *)beginActionTableControlWithTarget:(id<ActionControllerDelegate>)target Titles:(NSArray<NSString *> *)titles location:(CGPoint)location userObj:(id)obj identifier:(NSString *)identifier{
    ActionTableView *actionTable = [[ActionTableView alloc] initWithTitles:titles location:location target:target userObj:obj identifier:identifier];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:actionTable];
    [window bringSubviewToFront:actionTable];
    [actionTable animateWithView];
    return actionTable;
}
@end
