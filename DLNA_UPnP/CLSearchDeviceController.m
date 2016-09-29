//
//  CLSearchDeviceController.m
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLSearchDeviceController.h"
#import "CLUPnP/CLUPnP.h"

static NSString *cellIdentifier = @"cellIdentifier";
@interface CLSearchDeviceController ()<UITableViewDataSource, UITableViewDelegate, CLUdpAssociationDelegate>
{
    CLUdpAssociation *upd;
    NSSet *set;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *array;

@end

@implementation CLSearchDeviceController

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    upd = [[CLUdpAssociation alloc] init];
    upd.delegate = self;
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [upd search];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [upd stop];
}

#pragma mark -- 搜索协议回调 --
- (void)updSearchResultsWith:(CLUPnPModel *)model{
    [self.dataArray addObject:model];
    set = [NSSet setWithArray:[self.dataArray copy]];
    self.array = [set allObjects];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20);
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = NO;
    }
    return _tableView;
}

#pragma mark -
#pragma mark - UITableViewDelegate && UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row < self.array.count) {
        CLUPnPModel *model = self.array[indexPath.row];
        cell.textLabel.text = model.friendlyName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.array.count) {
        CLUPnPModel *model = self.array[indexPath.row];
        CLUPnPRenderer *render = [[CLUPnPRenderer alloc] initWithModel:model];
        [render setAVTransportURL:@"http://v.tiaooo.com/llbizosAzGhJPXC0H4AHLTGHl42W"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
