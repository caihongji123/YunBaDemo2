//
//  ImageViewController.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/29.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
-(instancetype)initWithImage:(UIImage *)image;
-(void)showWithLocation:(CGPoint)location imageViewSize:(CGSize)size delegate:(UIViewController *)con;
-(void)close;
@end
