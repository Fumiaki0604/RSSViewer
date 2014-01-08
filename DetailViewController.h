//
//  DetailViewController.h
//  RSSViewer
//
//  Created by 佐藤　史渉 on 2013/11/15.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate,UIWebViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIWebView *web_Viewer;

@property (copy,nonatomic) NSString *titleText;
@end
