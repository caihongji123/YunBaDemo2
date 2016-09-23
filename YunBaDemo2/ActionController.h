//
//  ActionController.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/20.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ActionControllerDelegate;

@interface ActionController : NSObject
+(void)beginActionControlWithTarget:(id<ActionControllerDelegate>)target Titles:(NSArray<NSString *> *)titles location:(CGPoint)location userObj:(id)obj;
@end

@protocol ActionControllerDelegate <NSObject>
@optional
-(void)actionControlDidAct:(NSInteger)index;
-(void)actionControlDidFinished:(id)userObj isCancel:(BOOL)value;
@end
