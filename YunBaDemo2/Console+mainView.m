//
//  Console+mainView.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/18.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "Console.h"
#import "TextView.h"
#import "Notifications.h"

#define TEXT_VIEW_LEADING 16
#define TEXT_VIEW_TRIALING 16
#define TEXT_VIEW_TOP 8
#define TEXT_VIEW_BOTTOM 16


@implementation Console (mainView)

#pragma mark - others <Publish> <PublishToAlias>
- (IBAction)tap:(id)sender {[self.view endEditing:YES]; }
- (IBAction)send:(id)sender {
    if ([self isNotEmpty:self.sendField.text]) {
        NSString * identifier = [GlobalAttribute sharedInstance].msgArray[0];
        NSRange range = [identifier rangeOfString:@":"];
        if (range.location == NSNotFound && range.length == 0) {
            [Notifications sendNotification:@"Topic or Alias not Found!"];
            return;
        }
        NSString *type = [identifier substringToIndex:range.location];
        NSString *aim = [identifier substringFromIndex:range.location + 1];
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:self.sendField.text forKey:@"Text"];
        [dict setObject:[GlobalAttribute sharedInstance].alias forKey:@"AliasName"];
        if ([type isEqualToString:@"Topic"]) {
            [dict setObject:@"Topic" forKey:@"Type"];
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            YBApnOption *apnOpt = [YBApnOption optionWithAlert:[NSString stringWithFormat:@"%@:%@",[GlobalAttribute sharedInstance].alias,self.sendField.text] badge:@(1) sound:@"default" contentAvailable:@(1) extra:@{@"json":dict}];
            YBPublish2Option *option = [YBPublish2Option optionWithApnOption:apnOpt];
            [YunBaService publish2:aim data:data option:option resultBlock:^(BOOL succ, NSError *error) {
                if (succ) {
                    NSLog(@"Success! Publish to topic : <%@> data: <%@>",aim,data);
                    MsgObj *obj = [[MsgObj alloc] initWithTopic:aim payload:data];
                    [[GlobalAttribute sharedInstance] addObj:obj isRecv:NO];
                    [self.mainViewTableView reloadData];
                    [self scrollToBottom:self.mainViewTableView];
                    self.sendField.text = @"";
                }else {
                    NSLog(@"failed!");
                    [Notifications sendNotification:@"Publish to topic failed!"];
                }
            }];
        }else {
            [dict setObject:@"Alias" forKey:@"Type"];
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            YBApnOption *apnOpt = [YBApnOption optionWithAlert:[NSString stringWithFormat:@"%@:%@",[GlobalAttribute sharedInstance].alias,self.sendField.text] badge:@(1) sound:@"default" contentAvailable:@(1) extra:@{@"json":dict}];
            YBPublish2Option *option = [YBPublish2Option optionWithApnOption:apnOpt];
            [YunBaService publish2ToAlias:aim data:data option:option resultBlock:^(BOOL succ, NSError *error) {
                if (succ) {
                    NSLog(@"Success! Publish to alias: <%@> data: <%@>",aim,data);
                    MsgObj *obj = [[MsgObj alloc] initWithTopic:aim payload:data];
                    [[GlobalAttribute sharedInstance] addObj:obj isRecv:NO];
                    [self.mainViewTableView reloadData];
                    [self scrollToBottom:self.mainViewTableView];
                    self.sendField.text = @"";
                }else {
                    NSLog(@"Failed!");
                    [Notifications sendNotification:@"Publish to alias failed!"];
                }
            }];
        }
        NSLog(@"send!");
    }
}
- (IBAction)longPress:(UILongPressGestureRecognizer *)sender {
    //ActionController
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self send:self.sendButton];
    return YES;
}
#pragma mark - tableViewDelegate
-(NSInteger)mainView_numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

-(NSInteger)mainView_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    { return ((NSMutableArray *)[GlobalAttribute sharedInstance].msgArray[1]).count; }

-(CGFloat)mainView_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgObj *msg = [[GlobalAttribute sharedInstance].msgArray[1] objectAtIndex:indexPath.row];
    NSString *gapId;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Msg"];
    UIView *view = [cell viewWithTag:40];
    NSInteger btWidth = [self constantWithView:view identifier:@"Width"].constant;
    NSInteger gap = [self constantWithView:cell.contentView identifier:gapId].constant;
    CGFloat textWidth = [UIScreen mainScreen].bounds.size.width - btWidth - gap - TEXT_VIEW_TRIALING - TEXT_VIEW_LEADING;
    CGFloat textHeight = [TextView heightWithTitle:msg.alias text:msg.text width:textWidth];
    return textHeight + TEXT_VIEW_TOP + TEXT_VIEW_BOTTOM;
}
-(UITableViewCell *)mainView_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgObj *msg = [[GlobalAttribute sharedInstance].msgArray[1] objectAtIndex:indexPath.row];
    NSString *gapId;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Msg"];
    UIView *view = [cell viewWithTag:40];
    view.layer.cornerRadius = 6.0f;
    view.layer.masksToBounds = YES;
    NSInteger btWidth = [self constantWithView:view identifier:@"Width"].constant;
    NSInteger gap = [self constantWithView:cell.contentView identifier:gapId].constant;
    CGFloat textWidth = [UIScreen mainScreen].bounds.size.width - btWidth - gap - TEXT_VIEW_TRIALING - TEXT_VIEW_LEADING;
    TextView *textView = [[TextView alloc] initWithTitle:msg.alias text:msg.text width:textWidth];
    textView.tag = 41;
    textView.frame = CGRectMake(TEXT_VIEW_LEADING + btWidth + gap,TEXT_VIEW_TOP, textView.frame.size.width, textView.frame.size.height);
    UIView *oldTextView = [cell.contentView viewWithTag:41];
    [oldTextView removeFromSuperview];
    [cell.contentView addSubview:textView];
    
    return cell;
}
-(CGFloat)mainView_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
-(UIView *)mainView_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
    {return nil;}
-(void)mainView_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}

@end
