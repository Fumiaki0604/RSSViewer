//
//  RSSTopicViewController.h
//  RSSViewer
//
//  Created by 佐藤　史渉 on 2013/11/15.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface RSSTopicViewController : UITableViewController
<NSXMLParserDelegate,EGORefreshTableHeaderDelegate,
UITableViewDelegate,
UITableViewDataSource>
{
    // 更新中を表示するView
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    // Cellの文字列、更新時に変更
    NSString *_cell_string;
}

@property(copy,nonatomic)NSString *url;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

-(NSMutableArray *)loadXML:(NSString *)urlstring;
@end
