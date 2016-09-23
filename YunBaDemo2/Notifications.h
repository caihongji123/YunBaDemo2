//
//  Notifications.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/19.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notifications : NSObject
+(void)sendNotification:(NSString *)content;
+(CGSize)sizeFromCurrentWidth:(CGFloat)width text:(NSString *)text font:(UIFont *)font;
@end
