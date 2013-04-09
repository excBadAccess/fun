//
//  Information.h
//  Fun
//
//  Created by administration on 13-3-22.
//  Copyright (c) 2013年 administration. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Information : NSObject

@property (nonatomic,copy)NSString * author;//作者名称
@property (nonatomic,copy)NSString * content;//正文
@property (nonatomic,copy)NSString * tag;//标签
@property (nonatomic,assign)int upCount;//顶的数量
@property (nonatomic,assign)int downCount;//踩的数量
@property (nonatomic,assign)int commentCount;//评论数量

@property (nonatomic,copy)NSString * funID;//信息ID
@property (nonatomic,copy)NSString * imageURL;//小图链接
@property (nonatomic,copy)NSString * imageOriginalURL;//原始链接
@property (nonatomic,assign)NSTimeInterval postTime;//发表时间

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
