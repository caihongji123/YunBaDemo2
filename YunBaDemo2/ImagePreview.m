//
//  ImagePreview.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/28.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "ImagePreview.h"
#import "GlobalAttribute.h"

#define IMAGE_PREVIEW_HEIGHT 200
@interface ImagePreview () <UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIView   * cardView;
@property (nonatomic,strong) UIButton * confirmButton;
@property (nonatomic,strong) UIButton * cancelButton;
@end

@implementation ImagePreview
-(instancetype)initWithImage:(UIImage *)image locationY:(CGFloat)locationY {
    if (self = [super init]) {
         _image = image;
        CGSize size = [[UIScreen mainScreen] bounds].size;
        self.frame = CGRectMake(0, 0, size.width, size.height);
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        _cardView = [[UIView alloc] init];
        _cardView.frame = CGRectMake(4, locationY - IMAGE_PREVIEW_HEIGHT + 4, size.width - 8, IMAGE_PREVIEW_HEIGHT - 8);
        _cardView.backgroundColor = STYLE_COLOR;
        _cardView.layer.cornerRadius = 6.0f;
        _cardView.layer.shadowOpacity = 0.4f;
        _cardView.userInteractionEnabled = YES;
        _cardView.tag = 10;
        // imageView
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_image];
        imageView.frame = CGRectMake(0, 0, _cardView.frame.size.width - 16, _cardView.frame.size.height - 16);
        imageView.center = CGPointMake(_cardView.frame.size.width / 2, _cardView.frame.size.height / 2);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_cardView addSubview:imageView];
        // button
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        [_confirmButton.titleLabel setFont:[UIFont fontWithName:TEXT_FONT size:17]];
        [_confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton sizeToFit];
        _confirmButton.frame = CGRectMake(_cardView.frame.size.width - _confirmButton.frame.size.width - 4,
                                          _cardView.frame.size.height - _confirmButton.frame.size.height - 4, _confirmButton.frame.size.width, _confirmButton.frame.size.height);
        [_cardView addSubview:_confirmButton];
        
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont fontWithName:TEXT_FONT size:17]];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton sizeToFit];
        _cancelButton.frame = CGRectMake( 4, _cardView.frame.size.height - _cancelButton.frame.size.height - 4, _cancelButton.frame.size.width, _cancelButton.frame.size.height);
        [_cardView addSubview:_cancelButton];
        
        [self addSubview:_cardView];
        
    }
    return self;
}
-(void)tap:(id)sender {[self close];}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view.tag == 10) {return NO;}
    return YES;
}
-(void)show {
    UIWindow *win = [[UIApplication sharedApplication].delegate window];
    [win addSubview:self];
    [win bringSubviewToFront:self];
    self.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{self.alpha = 1;}];
}
-(void)close {
    self.alpha = 1;
    [UIView animateWithDuration:0.2 animations:^{self.alpha = 0;}
    completion:^(BOOL finished) {[self removeFromSuperview];}];
}

-(void)confirm:(id)sender {
    if ([self.delegate respondsToSelector:@selector(ImagePreview:didConfrim:)])
        {[self.delegate ImagePreview:self didConfrim:YES];}
    [self close];
}
-(void)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(ImagePreview:didConfrim:)])
        {[self.delegate ImagePreview:self didConfrim:NO];}
    [self close];
}
@end
