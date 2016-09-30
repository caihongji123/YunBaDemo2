//
//  MsgObj.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/28.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "MsgObj.h"

/********************** msgObj *********************/
@implementation MsgObj
#define MSGOBJ_TEXT_KEY  @"msgObj_text"
#define MSGOBJ_TOPIC_KEY @"msgObj_topic"
#define MSGOBJ_ALIAS_KEY @"msgObj_alias"
#define MSGOBJ_TYPE2_KEY  @"msgObj_type2"
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        if (aDecoder == nil) {return nil;}
        _topic = [aDecoder decodeObjectForKey:MSGOBJ_TOPIC_KEY];
        _alias = [aDecoder decodeObjectForKey:MSGOBJ_ALIAS_KEY];
        _text = [aDecoder decodeObjectForKey:MSGOBJ_TEXT_KEY];
        _type2 = ((NSNumber *)[aDecoder decodeObjectForKey:MSGOBJ_TYPE2_KEY]).integerValue;
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_topic forKey:MSGOBJ_TOPIC_KEY];
    [aCoder encodeObject:_alias forKey:MSGOBJ_ALIAS_KEY];
    [aCoder encodeObject:_text forKey:MSGOBJ_TEXT_KEY];
    [aCoder encodeObject:@(_type2) forKey:MSGOBJ_TYPE2_KEY];
}
-(instancetype)initWithTopic:(NSString *)topic payload:(NSData *)payload {
    if (self = [super init]) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:payload options:kNilOptions error:nil];
        if (!dict) {return nil;}
        NSString *topicType = [dict objectForKey:@"Type"];  if(!topicType){return nil;}
        _alias = [dict objectForKey:@"AliasName"];          if(!_alias){return nil;}
        _text = [dict objectForKey:@"Text"];                if(!_text){return nil;}
        _topic = topic;
        if ([topicType isEqualToString:@"Topic"])      {_type2 = MsgObjType2Topic;}
        else if([topicType isEqualToString:@"Alias"])  {_type2 = MsgObjType2Alias;}
        else                                           { return nil; }
    }
    return self;
}
@end
/************************** MsgImage *******************************/
@implementation MsgImage
#define MSGIMAGE_IMAGE_KEY  @"msgImage_image"
#define MSGIMAGE_QNKEY_KEY  @"msgImage_QNKey"
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        if (aDecoder == nil) {return nil;}
        _imageData = [aDecoder decodeObjectForKey:MSGIMAGE_IMAGE_KEY];
        _QNKey = [aDecoder decodeObjectForKey:MSGIMAGE_QNKEY_KEY];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_imageData forKey:MSGIMAGE_IMAGE_KEY];
    [aCoder encodeObject:_QNKey forKey:MSGIMAGE_QNKEY_KEY];
}
-(instancetype)initWithTopic:(NSString *)topic payload:(NSData *)payload {
    if (self = [super initWithTopic:topic payload:payload]) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:payload options:kNilOptions error:nil];
        if (!dict) {return nil;}
        NSString * DataType = [dict objectForKey:@"DataType"];  if(!DataType){return nil;}
        _QNKey = [dict objectForKey:@"QNKey"];                  if(!_QNKey){return nil;}
        if (![DataType isEqualToString:@"Image"])       {return nil;}
        _imageData = nil;
    }
    return self;
}
@end
/************************* MsgNameChanging ***********************/
@implementation MsgNameChanging
-(instancetype)initWithPayload:(NSData *)data {
    if (self = [super init]) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (![[dict objectForKey:@"Type"] isEqualToString:@"ChangeName"]) {
            return nil;
        }
        _type = MsgObjType2ChangeName;
        _oldAlias = [dict objectForKey:@"OldAlias"]; if(!_oldAlias) {return nil;}
        _alias = [dict objectForKey:@"NewAlias"];    if(!_alias) {return nil;}
    }
    return self;
}
@end
