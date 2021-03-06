//
//  Console+leftView.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/14.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "Console.h"

#define TABLEVIEW_HEIGHT 40
#define TABLEVIEW_HEADER_HEIGHT 40
@implementation Console (leftView)

#pragma mark - Action <getTopicList> <getAliasList>
-(void)getAliasWithTopic:(NSArray *)topicArray currentIndex:(NSInteger)currentIndex completon:(void(^)(void))completon{
    if (topicArray.count == 0) {return;}
    [YunBaService getAliasListV2:topicArray[currentIndex] resultBlock:^(NSDictionary *res, NSError *error) {
        if (error.code != kYBErrorNoError) { return; }
        NSMutableArray *aliases = [[res objectForKey:@"alias"] mutableCopy];
        if ([aliases containsObject:[GlobalAttribute sharedInstance].alias]) {
            [aliases removeObject:[GlobalAttribute sharedInstance].alias];
        }
        [[GlobalAttribute sharedInstance].topicAndAliases setObject:aliases forKey:topicArray[currentIndex]];
        [self.lefViewTableView reloadData];
        if (currentIndex < topicArray.count - 1) {
            [self getAliasWithTopic:topicArray currentIndex:currentIndex + 1 completon:completon];
        }else {
            if (completon) {completon();}
        }
    }];
}
-(void)topicsAndAliasesInit:(void(^)(void))completon {
    [YunBaService getAlias:^(NSString *res, NSError *error) {
        if (error.code != kYBErrorNoError) {
            NSLog(@"getAlias error:%@",error);
            return ;
        }
        [GlobalAttribute sharedInstance].alias = res;
        NSString * ALIAS = [GlobalAttribute sharedInstance].alias;
        [YunBaService getTopicList:ALIAS resultBlock:^(NSArray *res, NSError *error) {
            if (error.code != kYBErrorNoError) {
                NSLog(@"getTopicList Error:%@",error);
                return;
            }
            [GlobalAttribute sharedInstance].topicAndAliases = [NSMutableDictionary new];
            
            [self getAliasWithTopic:res currentIndex:0 completon:completon];
        }];
    }];
}
-(void)topicTap:(UIButton *)sender forEvent:(UIEvent *)event {
    NSLog(@"action");
    NSLog(@"%@",sender.titleLabel.text);
    NSString *topic = [sender.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[GlobalAttribute sharedInstance] changeMsgArray:topic type:MsgObjType2Topic];
    [self.mainViewTableView reloadData];
    [self.leftView_t hideLeftView:^{ [self deHighlight:sender]; }];
    [self scrollToBottom:self.mainViewTableView];
    self.naviBarTitle.title = topic;
}
-(void)topicLongpressed:(UILongPressGestureRecognizer *)reco {
    if (reco.state == UIGestureRecognizerStateBegan) {
        UIButton *button = (UIButton *)reco.view;
        NSString *topic = [button.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.selectedTopic = topic;
        CGPoint location = [reco locationInView:[[UIApplication sharedApplication].delegate window]];
        [ActionController beginActionCardControlWithTarget:self Titles:@[@"Unsubscribe",@"Subscribe presence",@"UnSubscribe presence"] location:location userObj:reco.view identifier:@"leftViewAction"];
    }
}

#pragma mark - YBAction <subscribePrecence> <unsubscribePresence> <unsubscribe>
-(void)unsubscribeTopic {
    NSLog(@"%@",self.selectedTopic);
    [YunBaService unsubscribe:self.selectedTopic resultBlock:^(BOOL succ, NSError *error) {
        if (succ) {
            [[GlobalAttribute sharedInstance] deleteTopicAndAliasData:self.selectedTopic];
            [self.mainViewTableView reloadData];
            [Notifications sendNotification:[NSString stringWithFormat:@"Unsubscribe [%@] success!",self.selectedTopic]];
        }else {
            [Notifications sendNotification:[NSString stringWithFormat:@"Unsubscribe [%@] failed!",self.selectedTopic]];
        }
    }];
    [self topicsAndAliasesInit:nil];
}
-(void)subscribePresence {
    [YunBaService subscribePresence:self.selectedTopic resultBlock:^(BOOL succ, NSError *error) {
        if (succ) {
            [Notifications sendNotification:[NSString stringWithFormat:@"Subscribe [%@]'s presence success!",self.selectedTopic]];
        }else {
            [Notifications sendNotification:[NSString stringWithFormat:@"Subscribe [%@]'s presence failed!",self.selectedTopic]];
        }
    }];
}
-(void)unsubscribePresence {
    [YunBaService unsubscribePresence:self.selectedTopic resultBlock:^(BOOL succ, NSError *error) {
        if (succ) {
            [Notifications sendNotification:[NSString stringWithFormat:@"Unsubscribe [%@]'s presence success!",self.selectedTopic]];
        }else {
            [Notifications sendNotification:[NSString stringWithFormat:@"Unsubscribe [%@]'s presence failed!",self.selectedTopic]];
        }
    }];
}

#pragma mark - helper
-(void)highlight:(UIButton *)sender {
    sender.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
}
-(void)deHighlight:(UIButton *)sender {
    sender.backgroundColor = [UIColor clearColor];
}

#pragma mark - tableView
-(NSInteger)leftView_numberOfSectionsInTableView:(UITableView *)tableView {
    return [[GlobalAttribute sharedInstance].topicAndAliases allKeys].count;
}
-(NSInteger)leftView_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *topic = [[GlobalAttribute sharedInstance].topicAndAliases allKeys][section];
    return ((NSArray *)[[GlobalAttribute sharedInstance].topicAndAliases objectForKey:topic]).count;
}
-(UIView *)leftView_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *topic = [[GlobalAttribute sharedInstance].topicAndAliases allKeys][section];
    UIView *topicView = [[UIView alloc] init];
    topicView.backgroundColor = self.leftView_t.backgroundColor;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont fontWithName:TOPIC_FONT size:17];
    [button setTitle:[NSString stringWithFormat:@"   %@",topic] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button addTarget:self action:@selector(topicTap:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [button addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(topicLongpressed:)]];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(10, 0, self.leftView_t.frame.size.width - 20, TABLEVIEW_HEADER_HEIGHT - 1);
    button.layer.cornerRadius = 8.0f;
    [button addTarget:self action:@selector(highlight:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(deHighlight:) forControlEvents:UIControlEventTouchDragOutside];
    [topicView addSubview:button];
    return topicView;
}
-(UITableViewCell *)leftView_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Alias"];
    CGRect frame = cell.frame;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:frame];
    cell.selectedBackgroundView.layer.cornerRadius = 5.0f;
    cell.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    UIView *ball = [cell viewWithTag:5];
    CGFloat width = 15;
    for (NSLayoutConstraint *c in ball.constraints) {
        if ([c.identifier isEqualToString:@"width"]) {
            width = c.constant;
        }
    }
    ball.layer.cornerRadius = width / 2;
    UILabel *label = [cell viewWithTag:6];
    label.font = [UIFont fontWithName:TEXT_FONT size:18];
    NSString *topic = [[GlobalAttribute sharedInstance].topicAndAliases allKeys][indexPath.section];
    label.text = ((NSArray *)[[GlobalAttribute sharedInstance].topicAndAliases objectForKey:topic])[indexPath.row];
    CGFloat h,s,b,a;
    [[UIColor whiteColor] getHue:&h saturation:&s brightness:&b alpha:&a];
    label.textColor = [UIColor colorWithHue:h saturation:s brightness:b * 0.85 alpha:a];
    return cell;
}
-(CGFloat)leftView_tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TABLEVIEW_HEADER_HEIGHT;
}
-(CGFloat)leftView_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLEVIEW_HEIGHT;
}
-(void)leftView_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *topic = [[GlobalAttribute sharedInstance].topicAndAliases allKeys][indexPath.section];
    NSString *alias = ((NSArray *)[[GlobalAttribute sharedInstance].topicAndAliases objectForKey:topic])[indexPath.row];
    [[GlobalAttribute sharedInstance] changeMsgArray:alias type:MsgObjType2Alias];
    [self.mainViewTableView reloadData];
    [self.leftView_t hideLeftView:^{
        [self scrollToBottom:self.mainViewTableView];
    }];
    self.naviBarTitle.title = alias;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
