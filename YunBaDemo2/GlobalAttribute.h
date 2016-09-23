//
//  GlobalAttribute.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/16.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Console;


#define TEXT_FONT @"GillSans"
#define TEXT_FONT_BOLD @"GillSans-SemiBold"
#define TOPIC_FONT @"ArialRoundedMTBold"
#define STYLE_COLOR [UIColor colorWithRed:60/255.0 green:42/255.0 blue:59/255.0 alpha:1.0]
#define DOT_COLOR [UIColor colorWithRed:60/255.0 green:131/255.0 blue:115/255.0 alpha:1.0]


typedef NS_ENUM(NSUInteger, MsgObjType2) {
    MsgObjType2Topic = 1,
    MsgObjType2Alias = 2,
    MsgObjType2ChangeName = 3
};

@interface MsgNameChanging : NSObject
@property (nonatomic)      MsgObjType2    type;
@property (nonatomic,copy) NSString     * oldAlias;
@property (nonatomic,copy) NSString     * alias;
-(instancetype)initWithPayload:(NSData *)data;
@end

@interface MsgObj : NSObject <NSCoding>
@property (nonatomic,copy) NSString     * topic;
@property (nonatomic,copy) NSString     * alias;
@property (nonatomic,copy) NSString     * text;
@property (nonatomic)      MsgObjType2     type2;
-(instancetype)initWithTopic:(NSString *)topic payload:(NSData *)payload;
@end

@interface GlobalAttribute : NSObject
@property (nonatomic,strong) NSString              * alias;
@property (nonatomic)        NSInteger               qosLevel;
@property (atomic,strong)    NSMutableDictionary   * topicAndAliases;
@property (nonatomic,weak)   Console               * consle;
@property (atomic,strong,readonly) NSMutableArray  * msgArray;
+(instancetype)sharedInstance;
-(NSString *)addObj:(MsgObj *)obj isRecv:(BOOL)isRecv;
-(void)deleteTopicAndAliasData:(NSString *)topic;
-(void)changeMsgArray:(NSString *)topic type:(MsgObjType2)type;
-(void)changeAliasName:(MsgNameChanging *)nameChanging;
@end
