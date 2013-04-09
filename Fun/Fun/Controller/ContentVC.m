//
//  ContentVC.m
//  Fun
//
//  Created by administration on 13-3-25.
//  Copyright (c) 2013年 administration. All rights reserved.
//

#import "ContentVC.h"
#import "MainTVC.h"
#import "DetailVC.h"
#import "Information.h"
//#import "ContentCell.h"
#import "PullingRefreshTableView.h"
#import "ASIHttpHeaders.h"
#import "JSONKit.h"

#import "MGScrollView.h"
#import "MGStyledBox.h"
#import "MGBoxLine.h"

#import "EGOImageButton.h"


@interface ContentVC ()<PullingRefreshTableViewDelegate,UITableViewDataSource,UITableViewDelegate,EGOImageButtonDelegate>

@property (nonatomic,strong) PullingRefreshTableView * tableView;//所显示的表格
@property (nonatomic,strong) NSMutableArray * list;//存储内容的数组
@property (nonatomic) BOOL refreshing;//是否重新载入
@property (nonatomic,assign) NSInteger page;//所显示数据的段数
@property (nonatomic,strong) ASIHTTPRequest * asiRequest;//HTTP请求
@property (nonatomic,assign) NSInteger titleNum;

@property (nonatomic,strong) EGOImageButton * imageButton;//图片
@property (nonatomic,assign) CGSize imageSize;

- (void) GetError:(ASIHTTPRequest *)request;//返回错误
- (void) GetResult:(ASIHTTPRequest *)request;//返回结果

@property (nonatomic,strong) Information * info;

@end

@implementation ContentVC


/*显示左侧筛选列表*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Fun";
    
    /*设置导航按钮*/
    
    UIImage * leftButtonImage = [UIImage imageNamed:@"leftButton"];
    UIButton * leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0,0,leftButtonImage.size.width,leftButtonImage.size.height);
    [leftButton addTarget:self action:@selector(showLeft:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * customLeftBarItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    self.navigationItem.leftBarButtonItem = customLeftBarItem;
    [customLeftBarItem release];    
    
    
    /*设置导航按钮*/
    
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation"] forBarMetrics:UIBarMetricsDefault];//设置导航栏图片
    
    self.asiRequest = nil;//将请求初始化为空
    
    if(self.page == 0)//如果目前载入的段数为0
    {
        [self.tableView launchRefreshing];//重新刷新数据
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(impress:) name:@"message" object:nil];//注册消息
}

- (void)impress:(NSNotification *)aNotification//获取消息中心的参数
{
    NSDictionary * dic = aNotification.userInfo;
    
    NSNumber * num = [dic objectForKey:@"key"];
    
    self.titleNum = [num intValue];
    
    switch (self.titleNum) {
        case 1:            
            self.title = @"最新鲜";
            break;
            
        case 2:
            self.title = @"有图有真相";
            break;
            
        case 3:
            self.title = @"推荐";
            break;
            
        case 4:
            self.title = @"按天分";
            break;
            
        case 5:
            self.title = @"按周分";
            break;
            
        case 6:
            self.title = @"按月分";
            break;
            
        default:
            break;
    }
    
    
    self.refreshing = YES;
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
    
}

- (void) showLeft:(id)sender//显示筛选菜单
{
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
}

- (void) viewWillAppear:(BOOL)animated//预载入筛选菜单
{
    [super viewWillAppear:animated];
    MainTVC * left = [[[MainTVC alloc] initWithStyle:UITableViewStylePlain]autorelease];//预载入
    [self.revealSideViewController preloadViewController:left forSide:PPRevealSideDirectionLeft];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*上拉下拉刷新数据*/


//释放内存
- (void)dealloc
{
    [_list release];
    _list = nil;
    [_tableView release];
    [super dealloc];
}

//载入视图
- (void)loadView
{
    [super loadView];
    _list = [[NSMutableArray alloc]init];
    
    CGRect bounds = self.view.bounds;
    bounds.size.height -= 44.f;//去掉导航条高度
    _tableView = [[PullingRefreshTableView alloc]initWithFrame:bounds pullingDelegate:self];//初始化为拖动刷新表视图
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//将分割线设置无
    _tableView.backgroundColor = [UIColor colorWithRed:0.29 green:0.32 blue:0.35 alpha:1];

    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}


#pragma mark - LoadData

/*请求数据*/


- (void)loadData
{
    self.page++;
    
    NSURL * url;
    
    switch (self.titleNum) {
        case 1:
            url = [NSURL URLWithString:LastestURLString(10, self.page)];
            break;
            
        case 2:
            url = [NSURL URLWithString:ImageURLString(10, self.page)];
            break;
            
        case 3:
            url = [NSURL URLWithString:SuggestURLString(10, self.page)];
            break;
            
        case 4:
            url = [NSURL URLWithString:DayURLString(10, self.page)];
            break;
            
        case 5:
            url = [NSURL URLWithString:WeakURlString(10, self.page)];
            break;
            
        case 6:
            url = [NSURL URLWithString:MonthURLString(10, self.page)];
            break;
            
        default:
            url = [NSURL URLWithString:LastestURLString(10, self.page)];
            break;
    }
    
    //登陆后检查网络
    self.asiRequest = [ASIHTTPRequest requestWithURL:url];
    [self.asiRequest setDelegate:self];
    [self.asiRequest setDidFinishSelector:@selector(GetResult:)];
    [self.asiRequest setDidFailSelector:@selector(GetError:)];
    [self.asiRequest startAsynchronous];
    

//    for (int i = 0; i < 10; i++) {
//        [self.list addObject:@"ROW"];
//    }
//    
//    if (self.page >= 3) {
//        [self.tableView tableViewDidFinishedLoadingWithMessage:@"All Loaded"];
//        self.tableView.reachedTheEnd = YES;//是否到达底部
//    }
//    else
//    {
//        [self.tableView tableViewDidFinishedLoading];
//        self.tableView.reachedTheEnd = NO;
//        [self.tableView reloadData];
//    }
    
}


- (void) GetError:(ASIHTTPRequest *)request
{
    self.refreshing = NO;
    [self.tableView tableViewDidFinishedLoading];//停止获取状态
    NSLog(@"获取数据失败");
}



- (void) GetResult:(ASIHTTPRequest *)request
{
    if (self.refreshing) {//是否重新载入
        self.page = 1;
        self.refreshing = NO;
        [self.list removeAllObjects];
    }
    NSLog(@"获取数据成功");
    
    NSData * data = [request responseData];
    NSDictionary * result = [data objectFromJSONData];
        
    if ([result objectForKey:@"items"]) {//如果字典内有items这个key
        NSArray * array = [NSArray arrayWithArray:[result objectForKey:@"items"]];
                
        for (NSDictionary *loop in array) {
            Information * info = [[[Information alloc]initWithDictionary:loop]autorelease];
            [self.list addObject:info];
        }
        
        NSLog(@"%i",[self.list count]);
    }    
    [self.tableView tableViewDidFinishedLoading];//停止获取状态
    [self.tableView reloadData];
}


#pragma mark - ImageButton

-(void)setImage:(NSInteger)row
{
    Information * info = [self.list objectAtIndex:row];
    
//    NSLog(@"%@",NSStringFromCGSize(self.imageButton.imageView.image.size));
    
    if (info.imageURL != nil) {
        [self.imageButton setImageURL:[NSURL URLWithString:info.imageURL]];
        [self.imageButton setFrame:CGRectMake(0, 0, self.imageSize.width, self.imageSize.height)];
        
//        NSLog(@"%@",info.imageURL);
//        NSLog(@"%@",info.funID);
//        [self imageButtonLoadedImage:self.imageButton];
        
        NSLog(@"1");
        
    } 
}

- (void)imageButtonLoadedImage:(EGOImageButton*)imageButton//回调方法，获得实际图片大小
{
//    NSLog(@"%@",NSStringFromCGSize(imageButton.imageView.image.size));
    NSLog(@"2");
    
    self.imageSize = imageButton.imageView.image.size;
    
    [self drawImage:self.imageSize];    
}


- (void)drawImage:(CGSize)imageSize
{
    float width = imageSize.width;
    float height = imageSize.height;
    float maxWidth = 80.f;
    float maxHeight = 61.f;
    
    
//    NSLog(@"=======================================================");
//    NSLog(@"width = %g height = %g",width,height);
  
    
    
    if(width > 0 && height > 0){
        
        if(width / height >= maxWidth / maxHeight)
        {
//            if(width > maxWidth){
//                width = maxWidth;
//                height = (height * maxWidth) / width;
//            }else{
//                //                imgd.width=image.width;
//                //                imgd.height=image.height;
//            }
            width = maxWidth;
            height = height * (maxWidth / imageSize.width);
        }
        else
        {            
//            if(height > maxHeight){
//                height = maxHeight;
//                width = (width * maxHeight) / height;
//            }else{
//                //                imgd.width=image.width;
//                //                imgd.height=image.height;
//            }
            height = maxHeight;
            width = width * (maxHeight / imageSize.height);
        }
    }

    
    
    
    self.imageSize = CGSizeMake(width, height);
    

   
//    NSLog(@"width = %g height = %g",width,height);
//    NSLog(@"=======================================================");
    
//    return imageSize;
}



#pragma mark - TableView



//计算cell内元素的高度
-(CGFloat) getTheHeight:(NSInteger)row
{
    Information * info = [self.list objectAtIndex:row];
    
    MGBoxLine * body  = [MGBoxLine multilineWithText:info.content font:nil padding:24];
    MGBoxLine * head = [MGBoxLine lineWithLeft:info.author right:nil];
    head.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    return body.frame.size.height + 20 + head.frame.size.height + head.frame.size.height +61;
}

//返回Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getTheHeight:indexPath.row];
}


//返回Cell的数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.list count];
//    NSLog(@"%i",[self.list count]);
}

//返回Cell的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    
    
//    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
//    }
    
   
    Information * info = [self.list objectAtIndex:[indexPath row]];
    
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    /*创建作者和正文*/
    
    MGBoxLine * body  = [MGBoxLine multilineWithText:info.content font:nil padding:24];//创建正文元素
    
    MGBoxLine * head = [MGBoxLine lineWithLeft:info.author right:nil];//创建作者元素
    head.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    
    /*创建作者和正文*/
    
    
//    UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
//    
//    image.image = [UIImage imageNamed:@"Icon@2x.png"];
    
    
    
    self.imageButton = [[EGOImageButton alloc]initWithPlaceholderImage:[UIImage imageNamed:@"default.png"] delegate:self];
    [self.imageButton setFrame:CGRectMake(20, 20, 80, 61)];
    
    [self.imageButton addTarget:self action:@selector(ImageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self addSubview:self.imageButton];
    
//    [self.imageButton setTitleEdgeInsets:UIEdgeInsetsMake(20.0, 0, 0, 0)];
    
    
    
    [self setImage:indexPath.row];
    
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
    
    [box.topLines addObject:self.imageButton];
    
    [box.topLines addObject:button];
    
    MGScrollView * scroller = [[[MGScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, body.frame.size.height + 48 + head.frame.size.height + head.frame.size.height + 61)]autorelease];
    
    [scroller.boxes addObject:box];
    
    scroller.alwaysBounceVertical = YES;
    scroller.delegate = self;
    [scroller drawBoxesWithSpeed:0];
  
    
    [cell.contentView addSubview:box];
    
    return cell;
    
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

//点击Cell时执行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//取消选中状态
    
//    DetailTVC * detail = [[[DetailTVC alloc]initWithStyle:UITableViewStyleGrouped :[self.list objectAtIndex:[indexPath row]]]autorelease];
    
    DetailVC * detail = [[[DetailVC alloc]initWithNibName:nil bundle:nil :[self.list objectAtIndex:[indexPath row]]]autorelease];
    
    [self.navigationController pushViewController:detail animated:YES];    
}

#pragma mark - PullingDelegate

//重新刷新的时候(往下拉)
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    self.refreshing = YES;//将refreshing的值为yes
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];//调用loadData方法
}

//显示刷新的时间
- (NSDate *)pullingTableViewRefreshingFinishedDate{
    
//    NSDateFormatter * df = [[NSDateFormatter alloc]init];
//    df.dateFormat = @"yyyy-MM-dd HH:mm";
//    NSDate * date = [df dateFromString:@"2012-05-03 10:10"];
//    [df release];
    
    NSDate * date = [NSDate date];
        
    return date;
}

//载入数据的时候(往下拉)
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
}

#pragma mark - Scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.tableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.tableView tableViewDidEndDragging:scrollView];
}










@end
