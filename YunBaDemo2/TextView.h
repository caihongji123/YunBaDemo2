//
//  TextView.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/21.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextView : UIView
-(instancetype)initWithTitle:(NSString *)title text:(NSString *)text width:(CGFloat)width;
+(CGFloat)heightWithTitle:(NSString *)title text:(NSString *)text width:(CGFloat)width;
@end
