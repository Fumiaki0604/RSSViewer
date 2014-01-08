//
//  MasterViewController.h
//  RSSViewer
//
//  Created by 佐藤　史渉 on 2013/11/15.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@class RSSTopicViewController;
@class DetailViewController;

@interface MasterViewController : UITableViewController<NSXMLParserDelegate>
{
    //名前格納用
    NSMutableArray *_nameArray;//rssの名称(DBより取得)
    NSMutableArray *_urlArray;//url(DBより取得)
    NSMutableArray *_iconArray;//iconのファイル名((DBより取得)
}

@end
