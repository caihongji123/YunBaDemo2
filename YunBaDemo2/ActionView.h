//
//  ActionView.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/27.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActionControllerDelegate;


@interface ActionCardView : UIView
@property (nonatomic, strong) NSArray                       * buttonArray;
@property (nonatomic, strong) UIView                        * cardView;
@property (nonatomic)         id<ActionControllerDelegate>    delegate;
@property (nonatomic)         id                              obj;
@property (nonatomic,copy) NSString                         * identifier;
-(instancetype)initWithTitles:(NSArray<NSString *> *)titles location:(CGPoint)location target:(id<ActionControllerDelegate>)target userObj:(id)obj identifier:(NSString *)identifier;
-(void)animateWithView;
@end

@interface ActionTableView : UIView <UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSArray                        * titlesArray;
@property (nonatomic, strong) UITableView                    * tableView;
@property (nonatomic)         id<ActionControllerDelegate>     delegate;
@property (nonatomic)         id                               obj;
@property (nonatomic,copy) NSString                          * identifier;
@property (nonatomic,strong) UIWindow *window;
-(instancetype)initWithTitles:(NSArray<NSString *> *)titles location:(CGPoint)location target:(id<ActionControllerDelegate>)target userObj:(id)obj identifier:(NSString *)identifier;
-(void)animateWithView;
-(void)close;
@end
