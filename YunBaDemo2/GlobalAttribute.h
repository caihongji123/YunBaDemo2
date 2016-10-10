//
//  GlobalAttribute.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/16.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgObj.h"
@class Console;
@class ActionTableView;


#define TEXT_FONT @"GillSans"
#define TEXT_FONT_BOLD @"GillSans-SemiBold"
#define TOPIC_FONT @"ArialRoundedMTBold"
#define STYLE_COLOR [UIColor colorWithRed:60/255.0 green:42/255.0 blue:59/255.0 alpha:1.0]
#define DOT_COLOR [UIColor colorWithRed:60/255.0 green:131/255.0 blue:115/255.0 alpha:1.0]

@interface GlobalAttribute : NSObject
@property (nonatomic,strong) NSString                           * alias;
@property (nonatomic)        NSInteger                            qosLevel;
@property (atomic,strong)    NSMutableDictionary                * topicAndAliases;
@property (nonatomic,weak)   Console                            * consle;
@property (atomic,strong,readonly) NSMutableArray               * msgArray;
@property (atomic,strong)    NSMutableArray<MsgNotification *>  * msgNotifications;
@property (nonatomic,weak)   ActionTableView                    * actionTable;
+(instancetype)sharedInstance;
-(NSString *)addObj:(MsgObj *)obj isRecv:(BOOL)isRecv;
-(void)deleteTopicAndAliasData:(NSString *)topic;
-(void)changeMsgArray:(NSString *)topic type:(MsgObjType2)type;
-(void)changeAliasName:(MsgNameChanging *)nameChanging;

-(void)addMsgNotifications:(MsgNotification *)msgNoti;
-(NSInteger)deleteMsgNotifications:(NSString *)uuid;
-(void)deleteAllMsgNotifications;
-(void)updateMsgNotifications;
@end
