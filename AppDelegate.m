//
//  AppDelegate.m
//  RSSViewer
//
//  Created by 佐藤　史渉 on 2013/11/15.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import "AppDelegate.h"
#import "RSSTopicViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //DBファイル名
    static NSString* const DB_FILE = @"forRSS.sqlite";
    
    //DBファイルへのパスを取得
    //パスは~/Documents/配下に格納される。
    NSString *dbPath = nil;
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    
    //取得データ数を確認
    if ([documentsPath count] >= 1) {
        //固定で0番目を取得でOK
        dbPath = [documentsPath objectAtIndex:0];
        //パスの最後にファイル名をアペンドし、DBファイルへのフルパスを生成。
        dbPath = [dbPath stringByAppendingPathComponent:DB_FILE];
        NSLog(@"db path : %@", dbPath);
    } else {
        //error
        NSLog(@"パスが見つかりません");
        return false;
    }
    
    //DBファイルがDocument配下に存在するか判定
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dbPath]) {
        //存在しない場合
        //デフォルトのDBファイルをコピー(初回のみ)
        //ファイルはアプリケーションディレクトリ配下に格納されている。
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *orgPath = [bundle bundlePath];
        //初期ファイルのパス。(~/XXX.app/igakukai.sqlite)
        //デフォルトのDBファイルをDocument配下へコピー
        orgPath = [orgPath stringByAppendingPathComponent:DB_FILE];
        
        //失敗した場合
        if (![fileManager copyItemAtPath:orgPath toPath:dbPath error:nil]) {
            //error
            NSLog(@"データベースファイルのコピーに失敗しました: %@ to %@.", orgPath, dbPath);
            return false;
        }
        else{
            NSLog(@"データベースファイルのコピー成功");
        }
    }

    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
