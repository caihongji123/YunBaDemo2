//
//  TextView.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/21.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "TextView.h"
#import "GlobalAttribute.h"

@implementation TextView
-(void)drawRect:(CGRect)rect {
    // change the view drawing
}
-(instancetype)initWithTitle:(NSString *)title text:(NSString *)text width:(CGFloat)width {
    if (self = [super init]) {
        // parentView init
        self.backgroundColor = [UIColor clearColor];
        
        // titleLabel init
        UILabel *titleLabel = [[UILabel alloc] init];
        UIFont *titleFont = [UIFont fontWithName:TOPIC_FONT size:17];
        CGFloat titleWidth = width - 8;
        CGSize titleSize = [TextView sizeFromCurrentWidth:titleWidth text:@"t" font:titleFont];
        titleLabel.text = title;
        titleLabel.numberOfLines = 1;
        titleLabel.frame = CGRectMake(4, 4, titleWidth, titleSize.height);
        titleLabel.font = titleFont;
        titleLabel.textColor = [UIColor blackColor];
        
        // textLabel init
        UILabel *textLabel = [[UILabel alloc] init];
        UIFont *textFont = [UIFont fontWithName:TEXT_FONT size:15];
        CGFloat textWidth = width - 8;
        CGSize textSize = [TextView sizeFromCurrentWidth:textWidth text:text font:textFont];
        textLabel.text = text;
        textLabel.numberOfLines = 0;
        textLabel.frame = CGRectMake(4, titleLabel.frame.size.height + 4, textWidth, textSize.height);
        textLabel.font = textFont;
        CGFloat h,s,b,a;
        [[UIColor grayColor] getHue:&h saturation:&s brightness:&b alpha:&a];
        textLabel.textColor = [UIColor colorWithHue:h saturation:s brightness:b * 0.4 alpha:a];
        textLabel.textAlignment = NSTextAlignmentLeft;
        
        // add view
        CGRect frame = CGRectZero;
        frame.size.width = width;
        frame.size.height = 4 + titleLabel.frame.size.height + 4 + textLabel.frame.size.height + 4;
        self.frame = frame;
        [self addSubview:titleLabel]; [self addSubview:textLabel];
    }
    return self;
}
+(CGSize)sizeFromCurrentWidth:(CGFloat)width text:(NSString *)text font:(UIFont *)font {
    CGSize size = CGSizeMake(width, 0);
    CGSize lableSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    return lableSize;
}

+(CGFloat)heightWithTitle:(NSString *)title text:(NSString *)text width:(CGFloat)width {
    UIFont *titleFont = [UIFont fontWithName:TEXT_FONT_BOLD size:17];
    CGSize titleSize = [TextView sizeFromCurrentWidth:width - 8 text:@"t" font:titleFont];
    
    UIFont *textFont = [UIFont fontWithName:TEXT_FONT size:15];
    CGSize textSize = [TextView sizeFromCurrentWidth:width - 8 text:text font:textFont];
    
    return 4 + titleSize.height + 4 + textSize.height + 4;
    
}
@end

@implementation TextImageView
#define IMAGE_VIEW_HEIGHT 80
-(instancetype)initWithTitle:(NSString *)title image:(UIImage *)image width:(CGFloat)width target:(id)target action:(SEL)action {
    if (self = [super init]) {
        // parentView init
        self.backgroundColor = [UIColor clearColor];
        // titleLabel init
        UILabel *titleLabel = [[UILabel alloc] init];
        UIFont *titleFont = [UIFont fontWithName:TOPIC_FONT size:17];
        CGFloat titleWidth = width - 8;
        CGSize titleSize = [TextView sizeFromCurrentWidth:titleWidth text:@"t" font:titleFont];
        titleLabel.text = title;
        titleLabel.numberOfLines = 1;
        titleLabel.frame = CGRectMake(4, 4, titleWidth, titleSize.height);
        titleLabel.font = titleFont;
        titleLabel.textColor = [UIColor blackColor];
        
        // imageView init;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CGFloat imgWidth,imgHeight;
        if (image.size.width > width - 8)
        { imgWidth = width - 8;  imgHeight = imgWidth * (image.size.height / image.size.width); }
        else   { imgWidth = image.size.width; imgHeight = image.size.height; }
        imageView.frame = CGRectMake(4, titleLabel.frame.size.height + 4,imgWidth, imgHeight);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:action]];
        // add view
        CGRect frame = CGRectZero;
        frame.size.width = width;
        frame.size.height = 4 + titleLabel.frame.size.height + 4 + imageView.frame.size.height + 4;
        self.frame = frame;
        [self addSubview:titleLabel]; [self addSubview:imageView];
    }
    return self;
}
+(CGFloat)heightWithTilte:(NSString *)title image:(UIImage *)img width:(CGFloat)width {
    UIFont *titleFont = [UIFont fontWithName:TEXT_FONT_BOLD size:17];
    CGSize titleSize = [TextView sizeFromCurrentWidth:width - 8 text:@"t" font:titleFont];
    CGFloat imgWidth,imgHeight;
    if (img.size.width > width - 8)
           { imgWidth = width - 8;  imgHeight = imgWidth * (img.size.height / img.size.width); }
    else   { imgWidth = img.size.width; imgHeight = img.size.height; }
    return 4 + titleSize.height + 4 + imgHeight + 4;
}
@end
