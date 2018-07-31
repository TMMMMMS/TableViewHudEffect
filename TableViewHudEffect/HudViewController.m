//
//  HudViewController.m
//  Test
//
//  Created by TMS on 2018/7/31.
//  Copyright © 2018年 TMS. All rights reserved.
//

#import "HudViewController.h"
#import <Masonry.h>

@interface HudViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;
// headerView上的遮盖
@property (nonatomic, strong) UIView *hudView;
// 是否隐藏headerView
@property (nonatomic, assign) BOOL isHideView;
// headerView高度
@property (nonatomic, assign) CGFloat headerViewH;
@end

@implementation HudViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self configViews];
}

- (void)testAction {
    
    NSLog(@"可以点击");
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    
    NSLog(@"%s", __func__);
}

// 即将滑动时，将headerView放到tableView下册
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    self.headerView.hidden = NO;
    [self.view insertSubview:self.headerView atIndex:0];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    //    NSLog(@"%s", __func__);
    
    if (self.isHideView) {
        self.headerView.hidden = self.isHideView;
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //
        //        });
    } else {
        self.headerView.hidden = self.isHideView;
        [self.view bringSubviewToFront:self.headerView];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    //    NSLog(@"%s---%zd", __func__, decelerate);
    
    // 当tableView的contentInset值为初始状态，方式一的手势慢慢拖动tableView时，根据偏移量依据headerView来控制headerView是直接隐藏还是完全消失，吸附效果
    if (!decelerate) {
        
        CGFloat offsetY = scrollView.contentOffset.y;
        
        
        if (offsetY <= -self.headerViewH*0.5) {
            self.isHideView = NO;
            [self.tableView setContentOffset:CGPointMake(0, -self.headerViewH) animated:YES];
        }
        
        if (offsetY > -self.headerViewH*0.5 && offsetY <= 0) {
            self.isHideView = YES;
            [self.tableView setContentOffset:CGPointZero animated:YES];
        }
        
        if (offsetY > 0) {
            self.isHideView = YES;
        }
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
//    NSLog(@"%s", __func__);
    
    // 处理tableView滑动到顶部的bounce效果所引起的headerView消失问题
    if (scrollView.contentOffset.y <= -self.headerViewH) {
        [self.view bringSubviewToFront:self.headerView];
    }
}

// 控制导航栏和HeaderView的灰度显示
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat scale = (offsetY + self.headerViewH) / (self.headerViewH+10);
    if (scale > 0.6) {
        scale = 0.6;
    }
    self.hudView.alpha = scale;
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    // velocity.y不等于0，代表是方式二的滑动方式
    if (velocity.y != 0) {
        
        // 此刻正在进行方式一的下滑操作，并且做了一层限制，为了不让tableView直接滑动到底部
        if (velocity.y > 0) {
            if (!self.isHideView) {
                self.isHideView = YES;
                //            [self.tableViewController.tableView setContentOffset:CGPointZero animated:YES];
                CGPoint targetOffset = CGPointZero;
                targetContentOffset->x = targetOffset.x;
                targetContentOffset->y = targetOffset.y;
            }
        }
        
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = [NSString stringWithFormat:@"---->%zd", indexPath.row];
    
    return cell;
}

#pragma mark - Initialize
- (void)configViews {
    
    UIView *customNaviBar = [[UIView alloc] init];
    customNaviBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:customNaviBar];
    [customNaviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(@([UIApplication sharedApplication].statusBarFrame.size.height));
        make.height.equalTo(@44);
    }];
    
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [completeBtn addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
    completeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [customNaviBar addSubview:completeBtn];
    [completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-16);
        make.centerY.equalTo(customNaviBar);
    }];
    
    self.headerViewH = 133;
    
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@(self.headerViewH+64));
    }];
    
    self.hudView = [[UIView alloc] init];
    self.hudView.backgroundColor = [UIColor blackColor];
    self.hudView.alpha = 0.6;
    [self.view addSubview:self.hudView];
    [self.hudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.headerView);
        make.size.equalTo(self.headerView);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(@64);
        //            make.edges.equalTo(self.view);
    }];
    
    [self.view bringSubviewToFront:self.headerView];
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.contentInset = UIEdgeInsetsMake(self.headerViewH, 0, 0, 0);
    }
    return _tableView;
}

- (UIView *)headerView {
    
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor clearColor];
        [_headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
        
        UIView *tempBg = [[UIView alloc] init];
        tempBg.backgroundColor = [UIColor orangeColor];
        [_headerView addSubview:tempBg];
        [tempBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(_headerView);
            make.top.equalTo(@64);
        }];
        
        UILabel *sloganLabel = [[UILabel alloc] init];
        sloganLabel.text = @"一二三四二二三四";
        sloganLabel.textColor = [UIColor blackColor];
        sloganLabel.font = [UIFont boldSystemFontOfSize:24];
        [tempBg addSubview:sloganLabel];
        [sloganLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(tempBg);
            make.top.equalTo(tempBg);
        }];
        
        UILabel *introLabel = [[UILabel alloc] init];
        introLabel.text = @"啦啦啦啦啦啦啦啦";
        introLabel.textColor = [UIColor blackColor];
        introLabel.font = [UIFont boldSystemFontOfSize:15];
        [tempBg addSubview:introLabel];
        [introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(tempBg);
            make.top.equalTo(sloganLabel.mas_bottom).offset(15);
        }];
        
        UIView *tempView = [[UIView alloc] init];
        tempView.backgroundColor = [UIColor redColor];
        [tempBg addSubview:tempView];
        [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@35);
            make.right.equalTo(@-35);
            make.top.equalTo(introLabel.mas_bottom).offset(10);
            make.height.equalTo(@60);
        }];
        
        UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [testBtn setTitle:@"测试点击" forState:UIControlStateNormal];
        [testBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [testBtn addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
        testBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [tempView addSubview:testBtn];
        [testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(tempView);
            make.centerY.equalTo(tempView);
            make.size.mas_equalTo(CGSizeMake(60, 30));
        }];
        
    }
    return _headerView;
}



@end
