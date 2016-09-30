//
//  QNGlobal.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/29.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QNGlobal : NSObject
+(void)getImageURL:(UIImage *)image complete:(void(^)(BOOL success,NSString *url))complete;
+(void)getImageWitKey:(NSString *)key complete:(void(^)(BOOL success,UIImage *image))complete;
@end
