//
//  GlobalAttribute.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/16.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "GlobalAttribute.h"

static GlobalAttribute *globalAttr;
#define QOS_LEVEL_KEY @"qos"

@interface GlobalAttribute ()
@property (atomic,strong,readwrite)   NSMutableArray  * msgArray;
@end
@implementation GlobalAttribute
-(instancetype)init {
    if (self = [super init]) {
        if (!globalAttr) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSNumber *qosObj = [userDefaults objectForKey:QOS_LEVEL_KEY];
            if (qosObj) {self.qosLevel = qosObj.integerValue;}
            else        {self.qosLevel = 0;}
            _topicAndAliases = [NSMutableDictionary new];
            _msgArray = [NSMutableArray new];
            [_msgArray addObject:@"none"];
            [_msgArray addObject:@[]];
            [self updateMsgNotifications];
        }
        globalAttr = self;
    }
    return self;
}
+(instancetype)sharedInstance {
    if (!globalAttr) {
        globalAttr = [[GlobalAttribute alloc] init];
    }
    return globalAttr;
}

-(void)setQosLevel:(NSInteger)qosLevel {
    _qosLevel = qosLevel;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(self.qosLevel) forKey:QOS_LEVEL_KEY];
}
-(NSString *)addObj:(MsgObj *)obj isRecv:(BOOL)isRecv {
    if (!obj) {return nil;}
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath, *identifier = nil, *searchAliasName;
    switch (obj.type2) {
        case MsgObjType2Alias:
            if (isRecv) {searchAliasName = obj.alias;}
            else        {searchAliasName = obj.topic;}
            for (NSString *key in [self.topicAndAliases allKeys]) {
                NSArray *array = [self.topicAndAliases objectForKey:key];
                if ([array containsObject:searchAliasName]) {
                    identifier = [NSString stringWithFormat:@"Alias:%@",searchAliasName];
                    break;
                }
            }if (!identifier) { return nil; }
            filePath = [path stringByAppendingPathComponent:identifier]; break;
        case MsgObjType2Topic:
            identifier = [NSString stringWithFormat:@"Topic:%@",obj.topic];
            filePath = [path stringByAppendingPathComponent:identifier]; break;
        default:break;
    }
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (!array) { array = [NSMutableArray new];}
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [array addObject:data];
    [NSKeyedArchiver archiveRootObject:array toFile:filePath];
    if ([_msgArray[0] isEqualToString:identifier]) {
        _msgArray[1] = [NSMutableArray new];
        for (NSData * subData in array) {
            id obj = [NSKeyedUnarchiver unarchiveObjectWithData:subData];
            [_msgArray[1] addObject:obj];
        }
    }
    return identifier;
}
-(void)deleteTopicAndAliasData:(NSString *)topic {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath, *identifier = nil;
    NSArray *array = [self.topicAndAliases objectForKey:topic];
    for (NSString *alias in array) {
        BOOL isExistInOthers = NO;
        for (NSString *key in [self.topicAndAliases allKeys]) {
            if (![key isEqualToString:topic]) {
                NSArray *otherTopicArray = [self.topicAndAliases objectForKey:key];
                if ([otherTopicArray containsObject:alias])
                    {isExistInOthers = YES; break; }
            }
        }
        if(!isExistInOthers) {
            identifier = [NSString stringWithFormat:@"Alias:%@",alias];
            filePath = [path stringByAppendingPathComponent:identifier];
            [manager removeItemAtPath:filePath error:nil];
            if ([_msgArray[0] isEqualToString:identifier]) {
                _msgArray[0] = @"none";_msgArray[1] = [NSMutableArray new];
            }
        }
    }
    identifier = [NSString stringWithFormat:@"Topic:%@",topic];
    filePath = [path stringByAppendingPathComponent:identifier];
    [manager removeItemAtPath:filePath error:nil];
    if ([_msgArray[0] isEqualToString:identifier]) {
        _msgArray[0] = @"none";_msgArray[1] = [NSMutableArray new];
    }
    
}
-(void)changeMsgArray:(NSString *)topic type:(MsgObjType2)type {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *identifier,*filePath;
    switch (type) {
        case MsgObjType2Alias:identifier = @"Alias:";break;
        case MsgObjType2Topic:identifier = @"Topic:";break;
        default:break;
    }  identifier = [identifier stringByAppendingString:topic];
    filePath = [path stringByAppendingPathComponent:identifier];
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    _msgArray[0] = identifier;
    _msgArray[1] = [NSMutableArray new];
    for (NSData * subData in array) {
        id obj = [NSKeyedUnarchiver unarchiveObjectWithData:subData];
        [_msgArray[1] addObject:obj];
    }
}
-(void)changeAliasName:(MsgNameChanging *)nameChanging {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *identifier,*oldFilePath,*filePath;
    NSFileManager *manager = [NSFileManager defaultManager];
    identifier = [NSString stringWithFormat:@"Alias:%@",nameChanging.oldAlias];
    oldFilePath = [path stringByAppendingPathComponent:identifier];
    identifier = [NSString stringWithFormat:@"Alias:%@",nameChanging.alias];
    filePath = [path stringByAppendingPathComponent:identifier];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:oldFilePath];
    if (array) {
        [manager removeItemAtPath:oldFilePath error:nil];
        [NSKeyedArchiver archiveRootObject:array toFile:filePath];
    }
}

-(void)addMsgNotifications:(MsgNotification *)msgNoti {
    if (!msgNoti) {return;}
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingPathComponent:@"msgNotifications"];
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (!array) { array = [NSMutableArray new];}
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:msgNoti];
    if (!data) {return;}
    [array addObject:data];
    [NSKeyedArchiver archiveRootObject:array toFile:filePath];
}
-(void)deleteAllMsgNotifications {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingPathComponent:@"msgNotifications"];
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (!array) {return;}
    [array removeAllObjects];
    [NSKeyedArchiver archiveRootObject:array toFile:filePath];
}
-(NSInteger)deleteMsgNotifications:(NSString *)uuid {
    if (!uuid) {return -1;}
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingPathComponent:@"msgNotifications"];
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (!array) {return -1;}
    NSData *aim; NSInteger index = -1;
    for (NSData *data in array) {
        MsgNotification *noti = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([noti.uuid isEqualToString:uuid])
            { aim = data; index = [[[array reverseObjectEnumerator]allObjects] indexOfObject:data];  break; }
    }
    [array removeObject:aim];
    [NSKeyedArchiver archiveRootObject:array toFile:filePath];
    return index;
    
}
-(void)updateMsgNotifications {
    self.msgNotifications = [NSMutableArray new];
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingPathComponent:@"msgNotifications"];
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (!array) {return;};
    for (NSData *data in [[array reverseObjectEnumerator] allObjects]) {
        MsgNotification *noti = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self.msgNotifications addObject:noti];
    }
}
@end

