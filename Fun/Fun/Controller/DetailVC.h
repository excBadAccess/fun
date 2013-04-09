//
//  DetailVC.h
//  Fun
//
//  Created by Mesiade on 13-3-31.
//  Copyright (c) 2013年 administration. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Information.h"

@interface DetailVC : UIViewController

@property (nonatomic,strong) Information * info;//初始化一条信息对象
//@property (nonatomic,strong) Information * info;//初始化一条信息对象
@property (nonatomic,strong) UITableView * infoTable;
@property (nonatomic,strong) UITableView * commentTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil :(Information *)info;

@end
