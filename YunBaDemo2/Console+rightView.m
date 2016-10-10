//
//  Console+rightView.m
//  YunBaDemo2
//
//  Created by 蔡弘基 on 16/10/2.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "Console.h"


@interface DeleteButton : UIButton
@property (nonatomic,copy) NSString      * uuid;
@property (nonatomic,strong) NSIndexPath * indexPath;
@end
@implementation DeleteButton @end

@implementation Console (rightView)

#pragma mark - Action
-(void)deleteButtonTap:(DeleteButton *)sender {
    NSInteger row = [[GlobalAttribute sharedInstance] deleteMsgNotifications:sender.uuid];
    if (row == -1) { return;}
    [[GlobalAttribute sharedInstance] updateMsgNotifications];
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
    [self.rightTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.rightTableView reloadData];
    });
}
- (IBAction)clearAll:(id)sender {
    NSInteger count = [GlobalAttribute sharedInstance].msgNotifications.count;
    if (count == 0) {return;}
    [[GlobalAttribute sharedInstance] deleteAllMsgNotifications];
    [[GlobalAttribute sharedInstance] updateMsgNotifications];
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i <count; i++) {
        [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.rightTableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
}


#pragma mark - tableViewDelegate
-(NSInteger)rightView_numberOfSectionsInTableView:(UITableView *)tableView { return 1;}

-(NSInteger)rightView_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ return [GlobalAttribute sharedInstance].msgNotifications.count; }

-(CGFloat)rightView_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static UITableViewCell * cell;
    if (!cell) { cell = [tableView dequeueReusableCellWithIdentifier:@"Notification"]; }
    MsgNotification *noti = [GlobalAttribute sharedInstance].msgNotifications[indexPath.row];
    NSLayoutConstraint *leading = [self constraintWithView:cell.contentView identifier:@"leading"];
    NSLayoutConstraint *trailing = [self constraintWithView:cell.contentView identifier:@"trailing"];
    NSLayoutConstraint *top = [self constraintWithView:cell.contentView identifier:@"top"];
    NSLayoutConstraint *bottom = [self constraintWithView:cell.contentView identifier:@"bottom"];
    NSLayoutConstraint *barHeight = [self constraintWithView:[cell.contentView viewWithTag:10]  identifier:@"height"];
    UILabel *message = [cell viewWithTag:14];
    CGFloat width = self.rightView_t.frame.size.width - leading.constant - trailing.constant;
    CGFloat height = [Notifications sizeFromCurrentWidth:width text:noti.message font:message.font].height + 1;
    return barHeight.constant + top.constant + height + bottom.constant;
}
-(UITableViewCell *)rightView_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Notification"];
    MsgNotification *noti = [GlobalAttribute sharedInstance].msgNotifications[indexPath.row];
    UILabel *title = [cell viewWithTag:13];
    DeleteButton *button = [cell viewWithTag:12];
    button.layer.cornerRadius = [self constraintWithView:button identifier:@"btWidth"].constant / 2;
    button.layer.masksToBounds = YES;
    button.uuid = noti.uuid;
    button.indexPath = indexPath;
    [button addTarget:self action:@selector(deleteButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *time = [cell viewWithTag:11];
    UILabel *message = [cell viewWithTag:14];
    time.text = [noti timeInterval];
    CGFloat barHeight = [self constraintWithView:[cell.contentView viewWithTag:10]  identifier:@"height"].constant;
    CGFloat timeWidth = [Notifications sizeFromCurrentHeight:barHeight text:time.text font:[UIFont fontWithName:TEXT_FONT size:17]].width;
    [self constraintWithView:time identifier:@"width"].constant = timeWidth;
    title.text = noti.title;
    message.text = noti.message;
    return cell;
}
-(CGFloat)rightView_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
-(UIView *)rightView_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
-(void)rightView_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}
- (IBAction)clearAllButton:(id)sender {
}
@end
