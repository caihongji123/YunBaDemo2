//
//  Console+mainView.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/18.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "Console.h"
#import "TextView.h"
#import "QNGlobal.h"
#import "ImageViewController.h"

#define TEXT_VIEW_LEADING 16
#define TEXT_VIEW_TRIALING 16
#define TEXT_VIEW_TOP 8
#define TEXT_VIEW_BOTTOM 16


@implementation Console (mainView)

#pragma mark - <Publish> <PublishToAlias>
- (IBAction)send:(id)sender {
    self.sendButton.enabled = NO;
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
        // Topic 频道的发送
        if ([type isEqualToString:@"Topic"]) {
            NSArray *remindAlias = [self remindParse:self.sendField.text]; // 解析需要 @ 的人
            [dict setObject:@"Topic" forKey:@"Type"];
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            YBPublish2Option *option = [YBPublish2Option optionWithApnOption:nil];
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
            [self remindTopicIfNeed:[NSString stringWithFormat:@"%@@了你",[GlobalAttribute sharedInstance].alias] topic:aim array:remindAlias]; // @ 相关人士
        // Alias 个人的发送
        }else {
            [dict setObject:@"Alias" forKey:@"Type"];
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            YBApnOption *apnOpt = [YBApnOption optionWithAlert:[NSString stringWithFormat:@"%@:%@",[GlobalAttribute sharedInstance].alias,self.sendField.text] badge:@(1) sound:@"default"];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ self.sendButton.enabled = YES;});
}
-(void)sendImage:(UIImage *)image {
    // identifier 示例："Topic:Yunba"/"Alias:caihongji"
    NSString * identifier = [GlobalAttribute sharedInstance].msgArray[0];
    NSRange range = [identifier rangeOfString:@":"];
    if (range.location == NSNotFound && range.length == 0) {
        [Notifications sendNotification:@"Topic or Alias not Found!"];
        return;
    }
    [QNGlobal getImageURL:image complete:^(BOOL success, NSString *url) {
        if (!success) { [Notifications sendNotification:@"Upload image failed!"]; return;}
        NSString *type = [identifier substringToIndex:range.location];
        NSString *aim = [identifier substringFromIndex:range.location + 1];
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:@"This is an image object" forKey:@"Text"];
        [dict setObject:[GlobalAttribute sharedInstance].alias forKey:@"AliasName"];
        [dict setObject:url forKey:@"QNKey"];
        [dict setObject:@"Image" forKey:@"DataType"];
        if ([type isEqualToString:@"Topic"]) {
            [dict setObject:@"Topic" forKey:@"Type"];
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            // "Alert = nil": 不显示推送通知
            YBApnOption *apnOpt = [YBApnOption optionWithAlert:nil badge:@(1) sound:@"default"];
            YBPublish2Option *option = [YBPublish2Option optionWithApnOption:apnOpt];
            // 推送
            [YunBaService publish2:aim data:data option:option resultBlock:^(BOOL succ, NSError *error) {
                if (succ) {
                    NSLog(@"Success! Publish to topic : <%@> data: <%@>",aim,data);
                    __block MsgImage *msgImage = [[MsgImage alloc] initWithTopic:aim payload:data];
                    [QNGlobal getImageWitKey:msgImage.QNKey complete:^(BOOL success, UIImage *image) {
                        if (!success) { return; }
                        msgImage.imageData = UIImageJPEGRepresentation(image, 1.0);
                        [[GlobalAttribute sharedInstance] addObj:msgImage isRecv:NO];
                        [self.mainViewTableView reloadData];
                        [self scrollToBottom:self.mainViewTableView];
                        self.sendField.text = @"";
                    }];
                }else {
                    NSLog(@"failed!");
                    [Notifications sendNotification:@"Publish to topic failed!"];
                }
            }];
        }else {
            [dict setObject:@"Alias" forKey:@"Type"];
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            YBApnOption *apnOpt = [YBApnOption optionWithAlert:[NSString stringWithFormat:@"%@给你发了张图片",[GlobalAttribute sharedInstance].alias] badge:@(1) sound:@"default"];
            YBPublish2Option *option = [YBPublish2Option optionWithApnOption:apnOpt];
            [YunBaService publish2ToAlias:aim data:data option:option resultBlock:^(BOOL succ, NSError *error) {
                if (succ) {
                    NSLog(@"Success! Publish to alias: <%@> data: <%@>",aim,data);
                    __block MsgImage *msgImage = [[MsgImage alloc] initWithTopic:aim payload:data];
                    [QNGlobal getImageWitKey:msgImage.QNKey complete:^(BOOL success, UIImage *image) {
                        if (!success) { return; }
                        msgImage.imageData = UIImageJPEGRepresentation(image, 1.0);
                        [[GlobalAttribute sharedInstance] addObj:msgImage isRecv:NO];
                        [self.mainViewTableView reloadData];
                        [self scrollToBottom:self.mainViewTableView];
                        self.sendField.text = @"";
                    }];
                }else {
                    NSLog(@"Failed!");
                    [Notifications sendNotification:@"Publish to alias failed!"];
                }
            }];
        }
    }];
}

#pragma mark - @ 相关
-(void)addRemindAliasWithIndex:(NSInteger)index {
    NSString *alias = [[GlobalAttribute sharedInstance].topicAndAliases objectForKey:self.naviBarTitle.title][index];
    alias = [alias stringByAppendingString:@" "];
    self.sendField.text = [self.sendField.text stringByAppendingString:alias];
}
-(NSArray<NSString *> *)remindParse:(NSString *)text {
    NSMutableArray *array = [NSMutableArray new];
    NSString *cpy = text;
    NSString *alias;
    for (;;) {
        NSRange tag = [cpy rangeOfString:@"@"];
        if (tag.location == NSNotFound && tag.length == 0) {return array;}
        if (tag.location != 0 && ![[cpy substringWithRange:NSMakeRange(tag.location - 1, 1)] isEqualToString:@" "]) {
            cpy = [cpy substringFromIndex:tag.location + 1];
            continue;
        }
        cpy = [cpy substringFromIndex:tag.location + 1];
        NSRange space = [cpy rangeOfString:@" "];
        if (space.location == NSNotFound && space.length == 0)
        {[array addObject:cpy]; return array;}
        alias = [cpy substringToIndex:space.location];
        NSLog(@"firstAlias:%@",alias);
        if (![array containsObject:alias]) {[array addObject:alias];}
    }
    return array;
}
-(void)remindTopicIfNeed:(NSString *)text topic:(NSString *)topic array:(NSArray *)remindAlias {
    for (NSString *alias in remindAlias) {
        if ([[[GlobalAttribute sharedInstance].topicAndAliases objectForKey:topic] containsObject:alias]) {
            YBApnOption *rmApnOpt = [YBApnOption optionWithAlert:text badge:@(1) sound:@"default"];
            YBPublish2Option *rmOpt = [YBPublish2Option optionWithApnOption:rmApnOpt];
            [YunBaService publish2ToAlias:alias data:[@"remind" dataUsingEncoding:NSUTF8StringEncoding] option:rmOpt resultBlock:^(BOOL succ, NSError *error) {
                if (succ) {
                    NSLog(@"remind %@ success!",alias);
                }else {
                    NSLog(@"remind %@ failed!",alias);
                }
            }];
        }
    }
}

#pragma mark - others
-(void)imageViewTap:(UITapGestureRecognizer *)reco {
    UIImageView *imageView = (UIImageView *)reco.view;
    CGPoint imgLocation = [reco locationInView:imageView];
    CGPoint winLocation = [reco locationInView:self.view];
    CGPoint imgCenter   = CGPointMake(imageView.frame.size.width / 2, imageView.frame.size.height / 2);
    CGFloat gapX =  imgCenter.x - imgLocation.x;
    CGFloat gapY =  imgCenter.y - imgLocation.y;
    CGPoint location = CGPointMake(winLocation.x + gapX, winLocation.y + gapY);
    ImageViewController *con = [[ImageViewController alloc] initWithImage:imageView.image];
    [con showWithLocation:location imageViewSize:imageView.frame.size delegate:self];
}
- (IBAction)tap:(id)sender {[self.view endEditing:YES]; }
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self send:self.sendButton];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([GlobalAttribute sharedInstance].actionTable)
    {[[GlobalAttribute sharedInstance].actionTable close];}
    NSLog(@"%lu",(unsigned long)range.location);
    NSString *pString = nil;
    if (range.location != 0)
    {pString = [textField.text substringWithRange:NSMakeRange(range.location - 1, 1)];}
    if ([string isEqualToString:@"@"] && ([pString isEqualToString:@" "] || pString == nil)) {
        CGPoint location;location.x = self.bottomView.frame.size.width / 2;location.y = self.bottomView.frame.origin.y;
        NSArray *array = [[GlobalAttribute sharedInstance].topicAndAliases objectForKey:self.naviBarTitle.title];
        [GlobalAttribute sharedInstance].actionTable = [ActionController beginActionTableControlWithTarget:self Titles:array  location:location userObj:nil identifier:@"noti"];
    }
    return YES;
}

#pragma mark - tableViewDelegate
-(NSInteger)mainView_numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

-(NSInteger)mainView_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    { return ((NSMutableArray *)[GlobalAttribute sharedInstance].msgArray[1]).count; }

-(CGFloat)mainView_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [[GlobalAttribute sharedInstance].msgArray[1] objectAtIndex:indexPath.row];
    MsgObjType MsgType;
    if ([obj isKindOfClass:[MsgImage class]]) {MsgType = MsgObjTypeImage;}
    else if([obj isKindOfClass:[MsgObj class]]) {MsgType = MsgObjTypeMsg;}
    else {return 0;}
    switch (MsgType) {
        case MsgObjTypeMsg: {
            MsgObj *msg = obj;
            static UITableViewCell *msgCell;
            if (!msgCell) { msgCell = [tableView dequeueReusableCellWithIdentifier:@"Msg"];}
            UIView *view = [msgCell viewWithTag:40];
            CGFloat btWidth = [self constraintWithView:view identifier:@"Width"].constant;
            CGFloat textWidth = [UIScreen mainScreen].bounds.size.width - btWidth - TEXT_VIEW_TRIALING - TEXT_VIEW_LEADING;
            CGFloat textHeight = [TextView heightWithTitle:msg.alias text:msg.text width:textWidth];
            return textHeight + TEXT_VIEW_TOP + TEXT_VIEW_BOTTOM;
        }break;
        case MsgObjTypeImage: {
            MsgImage *image = obj;
            static UITableViewCell *imageCell;
            if (!imageCell) { imageCell = [tableView dequeueReusableCellWithIdentifier:@"Image"]; }
            UIView *view = [imageCell viewWithTag:40];
            CGFloat btWidth = [self constraintWithView:view identifier:@"Width"].constant;
            CGFloat textWidth = [UIScreen mainScreen].bounds.size.width - btWidth - TEXT_VIEW_TRIALING - TEXT_VIEW_LEADING;
            CGFloat textHeight = [TextImageView heightWithTilte:image.alias image:[UIImage imageWithData:image.imageData] width:textWidth];
            return textHeight + TEXT_VIEW_TOP + TEXT_VIEW_BOTTOM;
        }break;
        default:break;}
    return 0;
}
-(UITableViewCell *)mainView_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [[GlobalAttribute sharedInstance].msgArray[1] objectAtIndex:indexPath.row];
    MsgObjType MsgType;
    if ([obj isKindOfClass:[MsgImage class]]) {MsgType = MsgObjTypeImage;}
    else if([obj isKindOfClass:[MsgObj class]]) {MsgType = MsgObjTypeMsg;}
    else {return nil;}
    UITableViewCell *cell;
    switch (MsgType) {
        case MsgObjTypeMsg: {
            MsgObj *msg = obj;
            cell = [tableView dequeueReusableCellWithIdentifier:@"Msg"];
            UIView *view = [cell viewWithTag:40];
            view.layer.cornerRadius = 6.0f;
            view.layer.masksToBounds = YES;
            CGFloat btWith = [self constraintWithView:view identifier:@"Width"].constant;
            CGFloat textWidth = [UIScreen mainScreen].bounds.size.width - btWith - TEXT_VIEW_TRIALING - TEXT_VIEW_LEADING;
            TextView *textView = [[TextView alloc] initWithTitle:msg.alias text:msg.text width:textWidth];
            textView.tag = 41;
            textView.frame = CGRectMake(TEXT_VIEW_LEADING + btWith, TEXT_VIEW_TOP, textView.frame.size.width, textView.frame.size.height);
            UIView *oldTextView = [cell.contentView viewWithTag:41];
            [oldTextView removeFromSuperview];
            [cell.contentView addSubview:textView];
        }break;
        case MsgObjTypeImage: {
            MsgImage *image = obj;
            UIImage *img = [UIImage imageWithData:image.imageData];
            cell = [tableView dequeueReusableCellWithIdentifier:@"Image"];
            UIView *view = [cell viewWithTag:40];
            view.layer.cornerRadius = 6.0f;
            view.layer.masksToBounds = YES;
            CGFloat btWith = [self constraintWithView:view identifier:@"Width"].constant;
            CGFloat textWidth = [UIScreen mainScreen].bounds.size.width - btWith - TEXT_VIEW_TRIALING - TEXT_VIEW_LEADING;
            TextImageView *imageView = [[TextImageView alloc] initWithTitle:image.alias image:img width:textWidth target:self action:@selector(imageViewTap:)];
            
            imageView.tag = 41;
            imageView.frame = CGRectMake(TEXT_VIEW_LEADING + btWith, TEXT_VIEW_TOP, imageView.frame.size.width, imageView.frame.size.height);
            UIView *oldImageView = [cell.contentView viewWithTag:41];
            [oldImageView removeFromSuperview];
            [cell.contentView addSubview:imageView];
        }break;
        default:break;
    }
    return cell;
}
-(CGFloat)mainView_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
-(UIView *)mainView_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
    {return nil;}
-(void)mainView_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}


@end
