//
//  ImageViewController.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/29.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (nonatomic,strong) UIImage        * image;
@property (nonatomic,strong) UIImageView    * imageView;
@property (nonatomic,strong) UIScrollView   * scrollView;
@property (nonatomic)        CGPoint          location;
@property (nonatomic)        CGSize           size;
@end

@implementation ImageViewController
-(instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        _image = image;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    _scrollView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    _scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_scrollView];
    
    UIImageView * imageView = [[UIImageView alloc] initWithImage:_image];
    CGFloat imgWidth,imgHeight;
    if (_image.size.width > screenSize.width)
    { imgWidth = screenSize.width;  imgHeight = imgWidth * (_image.size.height / _image.size.width); }
    else   { imgWidth = _image.size.width; imgHeight = _image.size.height; }
    imageView.frame = CGRectMake(0, 0, imgWidth, imgHeight);
    imageView.center = CGPointMake(screenSize.width / 2, screenSize.height / 2);
    [_scrollView addSubview:imageView];
    _imageView = imageView;
    
    _scrollView.contentSize = _imageView.image.size;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [_scrollView setMaximumZoomScale:5];
    [_scrollView setZoomScale:1];
    [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    [self.view addSubview:_scrollView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                            scrollView.contentSize.height * 0.5 + offsetY);
}
-(void)tap:(id)sender {
    [self close];
}
-(void)showWithLocation:(CGPoint)location imageViewSize:(CGSize)size delegate:(UIViewController *)con {
    self.location = location;
    self.size = size;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIWindow *win = [[UIApplication sharedApplication].delegate window];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0;
    view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [win addSubview:view];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    [view addSubview:imageView];
    imageView.frame = CGRectMake(0, 0, size.width, size.height);
    imageView.center = location;
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat imgWidth,imgHeight;
        if (_image.size.width > screenSize.width)
        { imgWidth = screenSize.width;  imgHeight = imgWidth * (_image.size.height / _image.size.width); }
        else   { imgWidth = _image.size.width; imgHeight = _image.size.height; }
        imageView.frame = CGRectMake(0, screenSize.height / 2 - imgHeight / 2, imgWidth, imgHeight);
        view.alpha = 1;
    }completion:^(BOOL finished) {
        [con presentViewController:self animated:NO completion:^{
            [view removeFromSuperview];
        }];
    }];
}
-(void)close {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIWindow *win = [[UIApplication sharedApplication].delegate window];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [win addSubview:view];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    [view addSubview:imageView];
    CGFloat imgWidth,imgHeight;
    if (_image.size.width > screenSize.width)
    { imgWidth = screenSize.width;  imgHeight = imgWidth * (_image.size.height / _image.size.width); }
    else   { imgWidth = _image.size.width; imgHeight = _image.size.height; }
    imageView.frame = CGRectMake(0, screenSize.height / 2 - imgHeight / 2, imgWidth, imgHeight);
    [self dismissViewControllerAnimated:NO completion:^{
        [UIView animateWithDuration:0.2 animations:^{
            imageView.frame = CGRectMake(self.location.x - self.size.width / 2, self.location.y - self.size.height / 2, self.size.width, self.size.height);
            view.alpha = 0;
        }completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }];
}

@end
