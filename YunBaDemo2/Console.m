//
//  Console.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/14.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "Console.h"
#import "YunBaService.h"
#import "LeftView.h"

@interface Console ()<LeftViewDelegate>
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
    self.leftView.gestureView = self.mainView;
    self.leftView.delegate = self;
    // YB label
    UILabel *label = [self.mainView viewWithTag:20];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 5.0f;
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLeftView:)]];
    
    self.sendButton.layer.cornerRadius = 6.0f;
    
    [self topicsAndAliasesInit:nil];
    [self addNotificationHandler];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 键盘监听
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
}
-(void)showLeftView:(id)sender {
    [self.leftView showLeftView];
}
#pragma mark - keyboard
-(void)p_keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    [self constantWithView:self.mainView identifier:@"BottomViewBottm"].constant = keyboardRect.size.height;
    [self.view layoutIfNeeded];
    [self scrollToBottom:self.mainViewTableView];
    
}
-(void)p_keyboardWillDismiss:(NSNotification *)notification {
    [self.view layoutIfNeeded];
    [self constantWithView:self.mainView identifier:@"BottomViewBottm"].constant = 0;
}

#pragma mark - tableView routing
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView.tag == 11)
        return [self leftView_numberOfSectionsInTableView:tableView];
    else
        return [self mainView_numberOfSectionsInTableView:tableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 11)
        return [self leftView_tableView:tableView numberOfRowsInSection:section];
    else
        return [self mainView_tableView:tableView numberOfRowsInSection:section];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 11)
        return [self leftView_tableView:tableView cellForRowAtIndexPath:indexPath];
    else
        return [self mainView_tableView:tableView cellForRowAtIndexPath:indexPath];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 11)
        return [self leftView_tableView:tableView viewForHeaderInSection:section];
    else
        return [self mainView_tableView:tableView viewForHeaderInSection:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 11)
        return [self leftView_tableView:tableView heightForHeaderInSection:section];
    else
        return [self mainView_tableView:tableView heightForHeaderInSection:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 11)
        return [self leftView_tableView:tableView heightForRowAtIndexPath:indexPath];
    else
        return [self mainView_tableView:tableView heightForRowAtIndexPath:indexPath];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 11)
        [self leftView_tableView:tableView didSelectRowAtIndexPath:indexPath];
    else
        [self mainView_tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - helper
-(NSLayoutConstraint *)constantWithView:(UIView *)view identifier:(NSString *)identifier {
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
            NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
            [tableView scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

@end
