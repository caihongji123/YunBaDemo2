//
//  Console.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/14.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionController.h"
#import "YunBaService.h"
#import "Notifications.h"
#import "LeftView.h"
#import "GlobalAttribute.h"
@class LeftView;
@interface Console : UIViewController <UITableViewDelegate,UITableViewDataSource,ActionControllerDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView             * mainView;
@property (weak, nonatomic) IBOutlet UITableView        * mainViewTableView;
@property (weak, nonatomic) IBOutlet LeftView           * leftView_t;
@property (weak, nonatomic) IBOutlet UITableView        * lefViewTableView;
@property (weak, nonatomic) IBOutlet LeftView           * rightView_t;
@property (weak, nonatomic) IBOutlet UITableView        * rightTableView;
@property (weak, nonatomic) IBOutlet UIView             * bottomView;
@property (nonatomic,copy)           NSString           * selectedTopic;
@property (weak, nonatomic) IBOutlet UINavigationItem   * naviBarTitle;
@property (weak, nonatomic) IBOutlet UIButton           * sendButton;
@property (weak, nonatomic) IBOutlet UITextField        * sendField;
@property (weak, nonatomic) IBOutlet UIButton           * clearAllButton; // right view clear all button
-(NSLayoutConstraint *)constraintWithView:(UIView *)view identifier:(NSString *)identifier;
-(BOOL)isNotEmpty:(NSString *)text;
- (void)scrollToBottom:(UITableView *)tableView;

@end

@interface Console (leftView)
/********************   tableView ********************/
-(NSInteger)leftView_numberOfSectionsInTableView:(UITableView *)tableView;
-(NSInteger)leftView_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *)leftView_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)leftView_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
-(UIView *)leftView_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
-(CGFloat)leftView_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)leftView_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
/****************************************************/
-(void)topicsAndAliasesInit:(void(^)(void))completon;
-(void)deHighlight:(UIButton *)sender;
-(void)highlight:(UIButton *)sender;
-(void)unsubscribeTopic;
-(void)subscribePresence;
-(void)unsubscribePresence;
@end

@interface Console (rightView)

/******************** tableView ********************/
-(NSInteger)rightView_numberOfSectionsInTableView:(UITableView *)tableView;
-(NSInteger)rightView_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *)rightView_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)rightView_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
-(UIView *)rightView_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
-(CGFloat)rightView_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)rightView_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
/**************************************************/
@end


@interface Console (mainView)
/******************** tableView ********************/
-(NSInteger)mainView_numberOfSectionsInTableView:(UITableView *)tableView;
-(NSInteger)mainView_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *)mainView_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)mainView_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
-(UIView *)mainView_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
-(CGFloat)mainView_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)mainView_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
/**************************************************/
-(void)addRemindAliasWithIndex:(NSInteger)index;
-(void)sendImage:(UIImage *)image;
@end

@interface Console (msgHandle)
- (void)addNotificationHandler;
@end
