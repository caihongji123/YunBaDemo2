//
//  Setting.m
//  YunBaDemo2
//
//  Created by 云巴pro on 16/9/14.
//  Copyright © 2016年 SHENZHEN WEIZHIYUN TECHNOLOGY CO.LTD. All rights reserved.
//

#import "Setting.h"
#import "YunBaService.h"
#import "GlobalAttribute.h"
#import "Notifications.h"
#import "Console.h"

@interface Setting () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UITextField        * aliasField;
@property (weak, nonatomic) UITextField        * topicField;
@property (weak, nonatomic) UIButton           * subscribeButton;
@property (weak, nonatomic) UISegmentedControl * qosSegment;

@end

@implementation Setting

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarSetting];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)navigationBarSetting {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 64)];
    UINavigationItem * navigationBarTitle = [[UINavigationItem alloc] initWithTitle:@"Settings"];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 130, 130)];
    title.font = [UIFont fontWithName:TEXT_FONT_BOLD size:20];
    title.text = @"Settings";
    title.textAlignment = NSTextAlignmentCenter;
    navigationBarTitle.titleView = title;
    [navigationBar pushNavigationItem: navigationBarTitle animated:YES];
    navigationBar.barTintColor = [UIColor whiteColor];
    
    [self.view addSubview:navigationBar];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
    item.style = UIBarButtonItemStyleDone;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont fontWithName:TEXT_FONT size:17];
    button.frame = CGRectMake(0, 0, 50, 40);
    [button setTitle:@"Done" forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [button addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    item.customView = button;
    navigationBarTitle.rightBarButtonItem = item;
    [navigationBar setItems:[NSArray arrayWithObject: navigationBarTitle]];
}
#pragma mark - Action <setAlias> <getAliasList> <subscribe>
- (IBAction)subscribe:(id)sender {
    NSLog(@"subscribe");
    [YunBaService getAliasListV2:self.topicField.text resultBlock:^(NSDictionary *res, NSError *error) {
        if (error.code != kYBErrorNoError) { return; }
        NSMutableArray *aliases = [[res objectForKey:@"alias"] mutableCopy];
        if (![aliases containsObject:[GlobalAttribute sharedInstance].alias]) {
            [YunBaService subscribe:self.topicField.text resultBlock:^(BOOL succ, NSError *error) {
                if (succ) {
                    NSLog(@"success subscribe topic : %@",self.topicField.text);
                    [Notifications sendNotification:[NSString stringWithFormat:@"success subscribe topic :\n%@",self.topicField.text]];
                    [[GlobalAttribute sharedInstance].consle topicsAndAliasesInit:nil];
                }else {
                    NSLog(@"subscribe topic: %@ failed",self.topicField.text);
                    [Notifications sendNotification:[NSString stringWithFormat:@"subscribe topic: %@ failed",self.topicField.text]];
                }
            }];
        }else { [Notifications sendNotification:@"Alias has already exist!"]; }
    }];
    [self.view endEditing:YES];
    
}
- (IBAction)qosLevelChange:(UISegmentedControl *)sender {
    NSInteger qos = [sender selectedSegmentIndex];
    [GlobalAttribute sharedInstance].qosLevel = qos;
}
- (void)done:(id)sender {
    if (![self.aliasField.text isEqualToString:[GlobalAttribute sharedInstance].alias]) {
        for (NSString *topic in [[GlobalAttribute sharedInstance].topicAndAliases allKeys]) {
            for (NSString *alias in [[GlobalAttribute sharedInstance].topicAndAliases objectForKey:topic]) {
                if ([self.aliasField.text isEqualToString:alias])
                    { [Notifications sendNotification:@"Alias has already exist!"]; return; }
            }
        }
        [YunBaService setAlias:self.aliasField.text resultBlock:^(BOOL succ, NSError *error) {
            if(succ) {
                NSLog(@"set alias Success!");
                if ([GlobalAttribute sharedInstance].alias) {
                    NSMutableDictionary *dict = [NSMutableDictionary new];
                    [dict setObject:@"ChangeName" forKey:@"Type"];
                    [dict setObject:[GlobalAttribute sharedInstance].alias forKey:@"OldAlias"];
                    [dict setObject:self.aliasField.text forKey:@"NewAlias"];
                    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
                    for (NSString *topic in [[GlobalAttribute sharedInstance].topicAndAliases allKeys]) {
                        YBApnOption *apnOpt = [YBApnOption optionWithAlert:[NSString stringWithFormat:@"有人改名了：%@ ==> %@",[GlobalAttribute sharedInstance].alias,self.aliasField.text] badge:@(1) sound:@"default"];
                        YBPublish2Option *option = [YBPublish2Option optionWithApnOption:apnOpt];
                        [YunBaService publish2:topic data:data option:option resultBlock:^(BOOL succ, NSError *error) {
                            if (succ) {
                                NSLog(@"Publish nameChanging to <%@> success!",topic);
                            }else
                                NSLog(@"Publish nameChanging to <%@> failed!",topic);
                        }];
                    }
                }
                [GlobalAttribute sharedInstance].alias = self.aliasField.text;
                [Notifications sendNotification:@"Set Alias success!"];
            }else {
                NSLog(@"set alias Failed");
                [Notifications sendNotification:@"Set Alias failed!"];
            }
        }];
    }
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    switch (section) {
        case 0:label.text = @"\tAlias";break;
        case 1:label.text = @"\tSubscribe a topic";break;
        case 2:label.text = @"\tQos Level";break;
       default:break;
    }
    label.font = [UIFont fontWithName:TEXT_FONT size:18];
    label.textColor = [UIColor grayColor];
    return label;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:{
            cell = [tableView dequeueReusableCellWithIdentifier:@"alias"];
            self.aliasField = [cell viewWithTag:10];
            self.aliasField.text = [GlobalAttribute sharedInstance].alias;
        }break;
        case 1:{
            cell = [tableView dequeueReusableCellWithIdentifier:@"subscribe"];
            self.topicField = [cell viewWithTag:11];
            self.subscribeButton = [cell viewWithTag:12];
        }break;
        case 2:{
            cell = [tableView dequeueReusableCellWithIdentifier:@"qosLevel"];
            self.qosSegment = [cell viewWithTag:13];
            self.qosSegment.selectedSegmentIndex = [GlobalAttribute sharedInstance].qosLevel;
            
        }break;
       default:break;
    }
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


@end
