//
//  ImagePreview.h
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/28.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagePreviewDelegate;

@interface ImagePreview : UIView
@property (nonatomic) id<ImagePreviewDelegate>    delegate;
@property (nonatomic,strong) NSString           * identifier;//You can identify this Object
@property (nonatomic,strong) UIImage            * image;
-(instancetype)initWithImage:(UIImage *)image locationY:(CGFloat)locationY;
-(void)show;
-(void)close;
@end

@protocol ImagePreviewDelegate <NSObject>
-(void)ImagePreview:(ImagePreview *)preView didConfrim:(BOOL)value;
@end
