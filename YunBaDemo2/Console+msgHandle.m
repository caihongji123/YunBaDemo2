//
//  Console+msgHandle.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/21.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "Console.h"
#import "Notifications.h"

@implementation Console (msgHandle)
#pragma mark - KVO
- (void)addNotificationHandler {
    NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC addObserver:self selector:@selector(onConnectionStateChanged:) name:kYBConnectionStatusChangedNotification object:nil];
    [defaultNC addObserver:self selector:@selector(onMessageReceived:) name:kYBDidReceiveMessageNotification object:nil];
    [defaultNC addObserver:self selector:@selector(onPresenceReceived:) name:kYBDidReceivePresenceNotification object:nil];
}
#pragma mark - YB message and presence receive
- (void)removeNotificationHandler {
    NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC removeObserver:self];
}
- (void)onConnectionStateChanged:(NSNotification *)notification {
    if ([YunBaService isConnected]) {
        NSLog(@"didConnect");
    } else {
        NSString *disconnectPrompt = [[notification object] objectForKey:kYBDisconnectPromptKey];
        NSString *prompt = [NSString stringWithFormat:@"disconnected [%@]", disconnectPrompt];
        NSLog(@"%@",prompt);
    }
}
- (void)onMessageReceived:(NSNotification *)notification {
    YBMessage *message = [notification object];
    NSLog(@"new message, %zu bytes, topic=%@", (unsigned long)[[message data] length], [message topic]);
    NSString *payloadString = [[NSString alloc] initWithData:[message data] encoding:NSUTF8StringEncoding];
    NSLog(@"data: %@ %@", payloadString,[message data]);
    MsgNameChanging *nameChanging = [[MsgNameChanging alloc] initWithPayload:[message data]];
    if (nameChanging) {
        [[GlobalAttribute sharedInstance] changeAliasName:nameChanging];
        [self topicsAndAliasesInit];
        return;
    }
    MsgObj *obj = [[MsgObj alloc] initWithTopic:[message topic] payload:[message data]];
    if ([obj.alias isEqualToString:[GlobalAttribute sharedInstance].alias])   {obj = nil;}
    if (obj) {
        NSString *identifier = [[GlobalAttribute sharedInstance] addObj:obj isRecv:YES];
        [self.mainViewTableView reloadData];
        [self scrollToBottom:self.mainViewTableView];
        if (![[GlobalAttribute sharedInstance].msgArray[0] isEqualToString:identifier]) {
            [Notifications sendNotification:[NSString stringWithFormat:@"Message from: [%@]",obj.alias]];
        }
    }
}
- (void)onPresenceReceived:(NSNotification *)notification {
    YBPresenceEvent *presence = [notification object];
    NSString *alias = [GlobalAttribute sharedInstance].alias;
    NSLog(@"%@  %@",[presence alias],alias);
    NSLog(@"new presence, action=%@, topic=%@, alias=%@, time=%lf", [presence action], [presence topic], [presence alias], [presence time]);
    NSString *curMsg = [NSString stringWithFormat:@"[Presence] %@:%@ => %@[%@]", [presence topic], [presence alias], [presence action], [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:[presence time]/1000] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle]];
    NSLog(@"%@",curMsg);
    if ([[presence alias] isEqualToString:alias]) {
        return;
    }
    [Notifications sendNotification:curMsg];
    [self topicsAndAliasesInit];
}


@end
