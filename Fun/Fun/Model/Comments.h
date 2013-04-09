//
//  Comments.h
//  Fun
//
//  Created by administration on 13-3-22.
//  Copyright (c) 2013年 administration. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comments : NSObject

@property (nonatomic,copy)NSString * funID;
@property (nonatomic,copy)NSString * reviewer;
@property (nonatomic,copy)NSString * content;
@property (nonatomic,assign)int floor;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
