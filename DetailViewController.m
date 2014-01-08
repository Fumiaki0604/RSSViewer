//
//  DetailViewController.m
//  RSSViewer
//
//  Created by 佐藤　史渉 on 2013/11/15.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController
{
    //ローディング用
    NSInteger flag;
    NSString *clickUrl;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}
@synthesize titleText;

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
        
        NSURL *url = [NSURL URLWithString:self.detailItem];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_web_Viewer loadRequest:request];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    flag = 0;
    //ページをWebViewのサイズに合わせて表示するよう設定
    _web_Viewer.scalesPageToFit = YES;
    _web_Viewer.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    //WebViewにdelegate先のオブジェクトを指定
    _web_Viewer.delegate = self;
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if(flag == 0)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_web_Viewer animated:YES];
        hud.labelText = @"Loading...";
        hud.dimBackground = YES;
        flag = 1;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self closeHud];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Webページのロード（表示）の開始前(YESでWebページの読み込みを行う、NOは何も処理を行わない)
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //リンクをクリックしたとき
    if (navigationType == UIWebViewNavigationTypeLinkClicked){
        clickUrl = [NSString stringWithFormat:@"%@",[request URL]];
        NSLog(@"%@",clickUrl);
        NSURL *opnUrl = [NSURL URLWithString:clickUrl];
        //リンク先をsafariで開く
        [[UIApplication sharedApplication] openURL:opnUrl];
        NSLog(@"リンクをクリック");
    }
    return YES;
}

- (void)dealloc {
    _web_Viewer.delegate = nil;
}

-(void)setFlag
{
    if(flag ==1)
    flag = 0;
    NSLog(@"%ld",(long)flag);
}

-(void)closeHud
{
    [MBProgressHUD hideAllHUDsForView:_web_Viewer animated:YES];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
