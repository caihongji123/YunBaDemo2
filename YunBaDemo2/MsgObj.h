//
//  MsgObj.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/28.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MsgObjType2) {
    MsgObjType2Topic = 1,
    MsgObjType2Alias = 2,
    MsgObjType2ChangeName = 3,
};
typedef NS_ENUM(NSUInteger, MsgObjType) {
    MsgObjTypeMsg,
    MsgObjTypeImage
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

@interface MsgImage : MsgObj
@property (nonatomic,strong)    NSData          * imageData;
@property (nonatomic,strong)    NSString        * QNKey;
-(instancetype)initWithTopic:(NSString *)topic payload:(NSData *)payload;
@end

@interface MsgNotification : NSObject <NSCoding>
@property (nonatomic,copy) NSString     * title;
@property (nonatomic,copy) NSString     * message;
@property (nonatomic,copy) NSDate       * date;
@property (nonatomic,copy) NSString     * uuid;
-(instancetype)initWithMsgObj:(MsgObj *)obj;
-(NSString *)timeInterval;
@end
