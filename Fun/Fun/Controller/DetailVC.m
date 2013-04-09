//
//  DetailVC.m
//  Fun
//
//  Created by Mesiade on 13-3-31.
//  Copyright (c) 2013年 administration. All rights reserved.
//

#import "DetailVC.h"
#import "Comments.h"

#import "ASIHttpHeaders.h"
#import "JSONKit.h"

#import "MGScrollView.h"
#import "MGStyledBox.h"
#import "MGBoxLine.h"

@interface DetailVC () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray * list;
@property (nonatomic,strong) ASIHTTPRequest * asiRequst;

@end

@implementation DetailVC

- (void)dealloc
{
    [_infoTable release];
    [_commentTable release];
    [_info release];
    [_asiRequst release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil :(Information *)info
{
    self.info = info;
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.29 green:0.32 blue:0.35 alpha:1];
    self.list = [[NSMutableArray alloc]init];
    
    /*设置返回按钮*/
    
    UIImage * backButtonImage = [UIImage imageNamed:@"backButton"];
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, backButtonImage.size.width, backButtonImage.size.height);
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * customBackBarItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = customBackBarItem;
    [customBackBarItem release];
    
    /*设置返回按钮*/
    
    //创建信息列表
    
    _infoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, [self getTheHeight])];
    _infoTable.backgroundColor = [UIColor clearColor];
    _infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _infoTable.dataSource = self;
    _infoTable.delegate = self;
    _infoTable.scrollEnabled = NO;
    [_commentTable addSubview:_infoTable];
    
    //创建评论列表
    _commentTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
    _commentTable.backgroundColor = [UIColor clearColor];
    _commentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _commentTable.dataSource = self;
    _commentTable.delegate = self;
    _commentTable.scrollEnabled = YES;
    [self.view addSubview:_commentTable];
    _commentTable.tableHeaderView = _infoTable;
    
    _asiRequst = nil;
    [self loadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Your Action*


//返回主页面
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

//计算cell内元素的高度
-(CGFloat) getTheHeight
{
    Information * info = self.info;
    
    MGBoxLine * body  = [MGBoxLine multilineWithText:info.content font:nil padding:24];
    MGBoxLine * head = [MGBoxLine lineWithLeft:info.author right:nil];
    head.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    return body.frame.size.height + 20 + head.frame.size.height + head.frame.size.height;
}

-(CGFloat) getTheHeightComment:(NSInteger)row
{
    Comments * comment = [self.list objectAtIndex:row];
    
    MGBoxLine * body  = [MGBoxLine multilineWithText:comment.content font:nil padding:24];
    MGBoxLine * head = [MGBoxLine lineWithLeft:comment.reviewer right:nil];
    head.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    return body.frame.size.height + 20 + head.frame.size.height;
}


#pragma mark - LoadData*

- (void)loadData
{
    [_list removeAllObjects];
    NSURL * url = [NSURL URLWithString:CommentsURLString(self.info.funID)];
    self.asiRequst = [ASIHTTPRequest requestWithURL:url];
    [self.asiRequst setDelegate:self];
    [self.asiRequst setDidFinishSelector:@selector(GetResult:)];
    [self.asiRequst setDidFailSelector:@selector(GetErr:)];
    [self.asiRequst startAsynchronous];
}

- (void) GetErr:(ASIHTTPRequest *)request
{
    
}

- (void) GetResult:(ASIHTTPRequest *)request
{
    NSData * data = [request responseData];//将获得的数据传给data
    NSDictionary * result = [data objectFromJSONData];//将data的数据通过json解析
    
    if ([result objectForKey:@"items"]) {
        NSArray * array = [NSArray arrayWithArray:[result objectForKey:@"items"]];
        for (NSDictionary * loop in array) {
            Comments * com = [[[Comments alloc]initWithDictionary:loop]autorelease];
            [self.list addObject:com];
        }
    }
    [self.commentTable reloadData];
}



#pragma mark - TableView*

- (NSInteger)tableView:(UITableView *)tableview numberOfRowsInSection:(NSInteger)section{
    if (tableview == _infoTable)
    {
        return 1;
    }
    else
    {
        return [self.list count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableview == _infoTable)
    {
        static NSString *identifier = @"_info";
        UITableViewCell *cell = [_infoTable dequeueReusableCellWithIdentifier:identifier];
        
//    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
//    }
        
        Information * info = self.info;
        
        cell.backgroundColor = [UIColor clearColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        
        MGBoxLine * body  = [MGBoxLine multilineWithText:info.content font:nil padding:24];//创建正文元素
        
        MGBoxLine * head = [MGBoxLine lineWithLeft:info.author right:nil];//创建作者元素
        head.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        
        /*创建按钮*/
        
        UIButton * up = [self button:[NSString stringWithFormat:@"赞 %i",info.upCount] for:nil];
        UIButton * down = [self button:[NSString stringWithFormat:@"踩 %i",info.downCount] for:nil];
        UIButton * comment = [self button:[NSString stringWithFormat:@"评论 %i",info.commentCount] for:nil];
        
        NSArray *left = [NSArray arrayWithObjects:up, down, nil];
        NSArray *right = [NSArray arrayWithObjects:comment, nil];
        
        MGBoxLine * button = [MGBoxLine lineWithLeft:left right:right];
        
        /*创建按钮*/
        
        MGStyledBox * box = [MGStyledBox box];
        [box.topLines addObject:head];
        [box.topLines addObject:body];
        [box.topLines addObject:button];
        
        MGScrollView * scroller = [[[MGScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, body.frame.size.height + 48 + head.frame.size.height + head.frame.size.height)]autorelease];
        
        [scroller.boxes addObject:box];
        
        scroller.alwaysBounceVertical = YES;
        scroller.delegate = self;
        [scroller drawBoxesWithSpeed:0];
        
        
        [cell.contentView addSubview:box];
        
        
        
        
        return cell;
    }
    else
    {
        static NSString *identifier = @"_comment";
        UITableViewCell *cell = [_infoTable dequeueReusableCellWithIdentifier:identifier];
        
//    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
//    }
        
        Comments * com = [self.list objectAtIndex:indexPath.row];
        
        cell.backgroundColor = [UIColor clearColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        MGBoxLine * body  = [MGBoxLine multilineWithText:com.content font:nil padding:24];//创建正文元素
        
        MGBoxLine * head = [MGBoxLine lineWithLeft:com.reviewer right:nil];//创建作者元素
        head.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];

        MGStyledBox * box = [MGStyledBox box];
        [box.topLines addObject:head];
        [box.topLines addObject:body];
        
        MGScrollView * scroller = [[[MGScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, body.frame.size.height + 20 + head.frame.size.height)]autorelease];
        
        [scroller.boxes addObject:box];
        
        scroller.alwaysBounceVertical = YES;
        scroller.delegate = self;
        [scroller drawBoxesWithSpeed:0];
        
        [cell.contentView addSubview:box];
        
        return cell;
    }
}

//cell上显示的按钮
- (UIButton *)button:(NSString *)title for:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    [button setTitleColor:[UIColor colorWithWhite:0.9 alpha:0.9]
                 forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor colorWithWhite:0.2 alpha:0.9]
                       forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    CGSize size = [title sizeWithFont:button.titleLabel.font];
    button.frame = CGRectMake(0, 0, size.width + 18, 26);
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:selector
     forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    button.backgroundColor = [UIColor colorWithRed:0.29 green:0.32 blue:0.35 alpha:1];;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 1);
    button.layer.shadowRadius = 0.8;
    button.layer.shadowOpacity = 0.6;
    return button;
}


- (CGFloat)tableView:(UITableView *)tableview heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableview == _infoTable)
    {        
        return [self getTheHeight];
    }
    else
    {
        return [self getTheHeightComment:indexPath.row];
    }
    
}




@end
