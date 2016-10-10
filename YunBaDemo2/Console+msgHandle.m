//
//  Console+msgHandle.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/21.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "Console.h"
#import "QNGlobal.h"

@implementation Console (msgHandle)

#pragma mark - KVO
-(void)addNotificationHandler {
    NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC addObserver:self selector:@selector(onConnectionStateChanged:) name:kYBConnectionStatusChangedNotification object:nil];
    [defaultNC addObserver:self selector:@selector(onMessageReceived:) name:kYBDidReceiveMessageNotification object:nil];
    [defaultNC addObserver:self selector:@selector(onPresenceReceived:) name:kYBDidReceivePresenceNotification object:nil];
}
-(void)onConnectionStateChanged:(NSNotification *)notification {
    if ([YunBaService isConnected]) { NSLog(@"didConnect"); }
    else {
        NSString *disconnectPrompt = [[notification object] objectForKey:kYBDisconnectPromptKey];
        NSString *prompt = [NSString stringWithFormat:@"disconnected [%@]", disconnectPrompt];
        NSLog(@"%@",prompt);
    }
}
-(void)onMessageReceived:(NSNotification *)notification {
    if ([GlobalAttribute sharedInstance].alias) { [self messageHandle:notification]; }
    else { [self topicsAndAliasesInit:^{ [self messageHandle:notification];}]; }
    
}
-(void)onPresenceReceived:(NSNotification *)notification {
    if ([GlobalAttribute sharedInstance].alias) { [self presenceHandle:notification]; }
    else { [self topicsAndAliasesInit:^{ [self presenceHandle:notification]; }]; }
}
-(void)removeNotificationHandler {
    NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC removeObserver:self];
}

#pragma mark - YB message and presence received handle
-(void)messageHandle:(NSNotification *)notification {
    YBMessage *message = [notification object];
    NSLog(@"new message, %zu bytes, topic=%@", (unsigned long)[[message data] length], [message topic]);
    NSString *payloadString = [[NSString alloc] initWithData:[message data] encoding:NSUTF8StringEncoding];
    NSLog(@"data: %@ %@", payloadString,[message data]);
    
    // 检查是否是改名消息
    MsgNameChanging *nameChanging = [[MsgNameChanging alloc] initWithPayload:[message data]];
    if (nameChanging) {
        [[GlobalAttribute sharedInstance] changeAliasName:nameChanging];
        [self topicsAndAliasesInit:nil];
        return;
    }
    // 检查是否是图片消息
    __block NSString *identifier;
    MsgImage *msgImage = [[MsgImage alloc] initWithTopic:[message topic] payload:[message data]];
    if (msgImage) {
        if ([msgImage.alias isEqualToString:[GlobalAttribute sharedInstance].alias])   {return;}
        [QNGlobal getImageWitKey:msgImage.QNKey complete:^(BOOL success, UIImage *image) {
            if (success) {
                msgImage.imageData = UIImageJPEGRepresentation(image, 1.0);
                identifier = [[GlobalAttribute sharedInstance] addObj:msgImage isRecv:YES];
                [self UIUpdate:msgImage identifier:identifier];
            }
        }];
        return;
    }
    // 检查是否是文本消息
    MsgObj *msg = [[MsgObj alloc] initWithTopic:[message topic] payload:[message data]];
    if (msg) {
        if ([msg.alias isEqualToString:[GlobalAttribute sharedInstance].alias])   {return;}
        identifier = [[GlobalAttribute sharedInstance] addObj:msg isRecv:YES];
        [self UIUpdate:msg identifier:identifier];
    }
}
-(void)presenceHandle:(NSNotification *)notification {
    YBPresenceEvent *presence = [notification object];
    NSString *alias = [GlobalAttribute sharedInstance].alias;
    NSLog(@"%@  %@",[presence alias],alias);
    NSLog(@"new presence, action=%@, topic=%@, alias=%@, time=%lf", [presence action], [presence topic], [presence alias], [presence time]);
    NSString *curMsg = [NSString stringWithFormat:@"[Presence] %@:%@ => %@[%@]", [presence topic], [presence alias], [presence action], [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:[presence time]/1000] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle]];
    NSLog(@"%@",curMsg);
    if ([[presence alias] isEqualToString:alias]) {return;}
    [Notifications sendNotification:curMsg];
    [self topicsAndAliasesInit:nil];
}
#pragma mark - helper
// 收到消息需要及时更新界面
-(void)UIUpdate:(MsgObj *)obj identifier:(NSString *)identifier {
    if ([[GlobalAttribute sharedInstance].msgArray[0] isEqualToString:identifier]) {
        [self.mainViewTableView reloadData];
        [self scrollToBottom:self.mainViewTableView];
    } else {
        MsgNotification *noti = [[MsgNotification alloc] initWithMsgObj:obj];
        [[GlobalAttribute sharedInstance] addMsgNotifications:noti];
        [[GlobalAttribute sharedInstance] updateMsgNotifications];
        [self.rightTableView reloadData];
        [self sendNotiByJudge:obj identifier:identifier];
    }
}
-(void)sendNotiByJudge:(MsgObj *)obj identifier:(NSString *)identifier {
    if (![obj.topic isEqualToString:[GlobalAttribute sharedInstance].alias]) {
        [Notifications sendNotification:[NSString stringWithFormat:@"Message from: [%@] alias: [%@]",obj.topic,obj.alias]];
    }else {
        [Notifications sendNotification:[NSString stringWithFormat:@"Message from alias: [%@]",obj.alias]];
    }
}

@end
