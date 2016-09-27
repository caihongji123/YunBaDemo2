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
#import "GlobalAttribute.h"
@class LeftView;
@interface Console : UIViewController <UITableViewDelegate,UITableViewDataSource,ActionControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView         * mainView;
@property (weak, nonatomic) IBOutlet UITableView *mainViewTableView;
@property (weak, nonatomic) IBOutlet LeftView       * leftView;
@property (weak, nonatomic) IBOutlet UITableView    * lefViewTableView;
@property (nonatomic,copy) NSString                 * selectedTopic;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviBarTitle;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *sendField;
-(NSLayoutConstraint *)constantWithView:(UIView *)view identifier:(NSString *)identifier;
-(BOOL)isNotEmpty:(NSString *)text;
- (void)scrollToBottom:(UITableView *)tableView;

@end

@interface Console (leftView)
-(NSInteger)leftView_numberOfSectionsInTableView:(UITableView *)tableView;
-(NSInteger)leftView_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *)leftView_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)leftView_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
-(UIView *)leftView_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
-(CGFloat)leftView_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)leftView_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)topicsAndAliasesInit:(void(^)(void))completon;
@end
@interface Console (mainView)
-(NSInteger)mainView_numberOfSectionsInTableView:(UITableView *)tableView;
-(NSInteger)mainView_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *)mainView_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)mainView_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
-(UIView *)mainView_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
-(CGFloat)mainView_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)mainView_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface Console (msgHandle)
- (void)addNotificationHandler;
@end
