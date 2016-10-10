//
//  Console.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/14.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "Console.h"
#import "YunBaService.h"
#import "Notifications.h"
#import "ImagePreview.h"

@interface Console ()<LeftViewDelegate,ImagePreviewDelegate>
@property (nonatomic) BOOL statusBarHidden;

@end

@implementation Console

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    [GlobalAttribute sharedInstance].consle = self;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.mainView.frame = CGRectMake(0, 0,screenSize.width, screenSize.height);
    [self.view addSubview:self.mainView];
    self.leftView_t.delegate = self;
    [self.leftView_t setGestureView:self.mainView withType:LeftViewTypeLeft viewRate:3/4.0f];
    
    self.rightView_t.delegate = self;
    [self.rightView_t setGestureView:self.mainView withType:LeftViewTypeRight viewRate:3/4.0f];
    self.clearAllButton.layer.cornerRadius = 6.0f;
    self.clearAllButton.layer.masksToBounds = YES;
    // YB label
    UILabel *label = [self.mainView viewWithTag:20];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 5.0f;
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImageAction:)]];
    self.sendButton.layer.cornerRadius = 6.0f;
    [self topicsAndAliasesInit:nil];
    [self addNotificationHandler];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_keyboardWillDismiss:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - others
-(BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}
-(void)leftViewMoveBegin:(LeftView *)leftView {
    [self.view endEditing:YES];
}
-(void)leftView:(LeftView *)leftView isShow:(BOOL)show {
    self.statusBarHidden = show ? YES : NO;
    [UIView animateWithDuration:0.2f animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
    if (show) {
        switch (leftView.type) {
            case LeftViewTypeLeft: [self.lefViewTableView reloadData];break;
            case LeftViewTypeRight: [self.rightTableView reloadData];break;
            default:break;
        }
    }
}
- (IBAction)showLeftView:(id)sender {
    [self.leftView_t showLeftView];
}
- (IBAction)showRightView:(id)sender {
    [self.rightView_t showLeftView];
}
#pragma mark - image
-(void)addImageAction:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *method = [self imageWithImage:image scaledToSize:CGSizeMake(image.size.width * 0.6, image.size.height * 0.6)];
    while (method.length/1000 > 500) {
        UIImage *tmp = [UIImage imageWithData:method];
        method = [self imageWithImage:tmp scaledToSize:CGSizeMake(tmp.size.width * 0.6, tmp.size.height * 0.6)];
    }
    NSLog(@"method:%luKB",(unsigned long)method.length / 1000);
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *img = [[UIImage alloc] initWithData:method];
        ImagePreview *preView = [[ImagePreview alloc] initWithImage:img locationY:self.bottomView.frame.origin.y];
        preView.delegate = self;
        [preView show];
    }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)ImagePreview:(ImagePreview *)preView didConfrim:(BOOL)value {
    if (value == YES) {[self sendImage:preView.image];}
}
#pragma mark - keyboard
-(void)p_keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    [self constraintWithView:self.mainView identifier:@"BottomViewBottm"].constant = keyboardRect.size.height;
    [self.view layoutIfNeeded];
    [self scrollToBottom:self.mainViewTableView];
    
}
-(void)p_keyboardWillDismiss:(NSNotification *)notification {
    [self.view layoutIfNeeded];
    [self constraintWithView:self.mainView identifier:@"BottomViewBottm"].constant = 0;
}
#pragma mark - ActionControl
-(void)actionControlDidFinished:(id)userObj isCancel:(BOOL)value identifier:(NSString *)identifier {
    if ([identifier isEqualToString:@"leftViewAction"]) {
        UIButton *button = userObj;
        [self deHighlight:button];
    }
}
-(void)actionControlDidAct:(NSInteger)index identifier:(NSString *)identifier {
    if ([identifier isEqualToString:@"leftViewAction"]) {
        switch (index) {
            case 0: [self unsubscribeTopic];break;
            case 1: [self subscribePresence];break;
            case 2: [self unsubscribePresence];break;
            default:NSLog(@"unknown ActionController action"); break;
        }
    }else if ([identifier isEqualToString:@"noti"]) {
        [self addRemindAliasWithIndex:index];
    }
}

#pragma mark - tableView routing
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if      (tableView.tag == 11) return [self leftView_numberOfSectionsInTableView:tableView];
    else if (tableView.tag == 12) return [self rightView_numberOfSectionsInTableView:tableView];
    else                          return [self mainView_numberOfSectionsInTableView:tableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if      (tableView.tag == 11) return [self leftView_tableView:tableView numberOfRowsInSection:section];
    else if (tableView.tag == 12) return [self rightView_tableView:tableView numberOfRowsInSection:section];
    else                          return [self mainView_tableView:tableView numberOfRowsInSection:section];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if      (tableView.tag == 11) return [self leftView_tableView:tableView cellForRowAtIndexPath:indexPath];
    else if (tableView.tag == 12) return [self rightView_tableView:tableView cellForRowAtIndexPath:indexPath];
    else                          return [self mainView_tableView:tableView cellForRowAtIndexPath:indexPath];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if      (tableView.tag == 11) return [self leftView_tableView:tableView viewForHeaderInSection:section];
    else if (tableView.tag == 12) return [self rightView_tableView:tableView viewForHeaderInSection:section];
    else                          return [self mainView_tableView:tableView viewForHeaderInSection:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if      (tableView.tag == 11) return [self leftView_tableView:tableView heightForHeaderInSection:section];
    else if (tableView.tag == 12) return [self rightView_tableView:tableView heightForHeaderInSection:section];
    else                          return [self mainView_tableView:tableView heightForHeaderInSection:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if      (tableView.tag == 11) return [self leftView_tableView:tableView heightForRowAtIndexPath:indexPath];
    else if (tableView.tag == 12) return [self rightView_tableView:tableView heightForRowAtIndexPath:indexPath];
    else                          return [self mainView_tableView:tableView heightForRowAtIndexPath:indexPath];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if      (tableView.tag == 11) [self leftView_tableView:tableView didSelectRowAtIndexPath:indexPath];
    else if (tableView.tag == 12) return [self rightView_tableView:tableView didSelectRowAtIndexPath:indexPath];
    else                          [self mainView_tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - helper
-(NSLayoutConstraint *)constraintWithView:(UIView *)view identifier:(NSString *)identifier {
    for (NSLayoutConstraint *con in view.constraints)
        if ([con.identifier isEqualToString:identifier]) { return con; }
    return nil;
}
-(BOOL)isNotEmpty:(NSString *)text {
    return !([[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]== 0);
}
- (void)scrollToBottom:(UITableView *)tableView {
    NSUInteger sectionCount = [tableView numberOfSections];
    if (sectionCount) {
        NSUInteger rowCount = [tableView numberOfRowsInSection:0];
        if (rowCount) {
            NSUInteger ii[2] = {0, rowCount - 1};
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
            [tableView scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}
- (NSData *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(newImage, 0.8);
}

+(CGSize)sizeFromCurrentWidth:(CGFloat)width text:(NSString *)text font:(UIFont *)font {
    CGSize size = CGSizeMake(width, 0);
    CGSize lableSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    return lableSize;
}

@end
