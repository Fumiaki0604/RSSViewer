//
//  titleClass.h
//  RSSViewer
//
//  Created by 佐藤　史渉 on 2013/12/02.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface rssClass : NSObject
{
    NSString *_title;
    NSString *_weburl;
    NSString *_icon;
}

@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *weburl;
@property(nonatomic,retain)NSString *icon;
@end
