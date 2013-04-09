//
//  Information.m
//  Fun
//
//  Created by administration on 13-3-22.
//  Copyright (c) 2013年 administration. All rights reserved.
//

#import "Information.h"

@implementation Information

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        id user = [dictionary objectForKey:@"user"];
        if ((NSNull *)user != [NSNull null]) {
            NSDictionary * user = [NSDictionary dictionaryWithDictionary:[dictionary objectForKey:@"user"]];
            self.author = [user objectForKey:@"login"];
        }
        else
        {
            self.author = @"匿名";
        }
        
        self.content = [dictionary objectForKey:@"content"];
        self.tag = [dictionary objectForKey:@"tag"];
        
        NSDictionary * votes = [NSDictionary dictionaryWithDictionary:[dictionary objectForKey:@"votes"]];
        self.upCount = [[votes objectForKey:@"up"]intValue];
        self.downCount = [[votes objectForKey:@"down"]intValue];
        
        self.commentCount = [[dictionary objectForKey:@"comments_count"]intValue];
        
        self.funID = [dictionary objectForKey:@"id"];
        self.postTime = [[dictionary objectForKey:@"published_at"]doubleValue];
        
        id image =[dictionary objectForKey:@"image"];
        if((NSNull *)image != [NSNull null])
        {
            self.imageURL = [dictionary objectForKey:@"image"];
            //http://pic.moumentei.com/system/pictures/2484/24846800/medium/app24846800.jpg
            
            
            NSString * subString = [self.funID substringWithRange:NSMakeRange(0, 4)];
            
//            NSLog(@"%@",subString);
            
            NSString * smallURL = [NSString stringWithFormat:@"http://pic.moumentei.com/system/pictures/%@/%@/small/%@",subString,self.funID,self.imageURL];
            NSString * mediumURL = [NSString stringWithFormat:@"http://pic.moumentei.com/system/pictures/%@/%@/medium/%@",subString,self.funID,self.imageURL];
            self.imageURL = smallURL;
            self.imageOriginalURL = mediumURL;
            
        }
    }
    return self;
}

- (void)dealloc
{
    self.author = nil;
    self.content = nil;
    self.tag = nil;
    self.funID = nil;
    self.imageURL = nil;
//    self.imageOriginalURL = nil;
    [super dealloc];
}

@end
