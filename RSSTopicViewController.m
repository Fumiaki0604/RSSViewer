//
//  RSSTopicViewController.m
//  RSSViewer
//
//  Created by 佐藤　史渉 on 2013/11/15.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "RSSTopicViewController.h"
#import "rssClass.h"

@implementation RSSTopicViewController
{
    NSArray *paths;
    NSString *documentsDirectory ;
    NSString *writableDBPath ;
    FMDatabase* forRSSDb;
    
    NSMutableArray *_objects;
    
    // title要素を格納する配列
    NSMutableArray *titleArray;
    // item要素のチェック
    BOOL itemElementCheck;
    // title要素のチェック
    BOOL titleElementCheck;
    // title要素のテキスト
    NSString *titleText;
    
    //pubDate要素を格納する配列
    NSMutableArray *dataArray;
    //pubDate要素のチェック
    BOOL dataElementCheck;
    //pubDate要素のテキスト(更新日付)
    NSString *dataText;
    // link要素を格納する配列
    NSMutableArray *linkArray;
    // link要素のチェック
    BOOL linkElementCheck;
    // link要素のテキスト
    NSString *linkText;
    NSMutableArray *alreadyreadUrl;
    NSString *tempUrl;
    NSString *kidoku;
    NSInteger unUsedTopic;
    NSInteger dataArrayCount;
    
}
@synthesize url;

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"ViewWillAppear");
    NSLog(@"添付%@",tempUrl);
    _objects = [NSMutableArray array];
    
    NSLog(@"%@",url);
    alreadyreadUrl = [[NSMutableArray alloc] init];
    //データベースの訪問済みurlを吸い出して、配列に代入
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"forRSS.sqlite"];
    
    forRSSDb = [FMDatabase databaseWithPath:writableDBPath];
    if(![forRSSDb open])
    {
        NSLog(@"Err %d: %@", [forRSSDb lastErrorCode], [forRSSDb lastErrorMessage]);
    }
    else{
        NSLog(@"データベースオープン");
    }
    
    [forRSSDb setShouldCacheStatements:YES];
    
    NSString* sql = @"SELECT * FROM urlTable ;";
    FMResultSet* rs = [forRSSDb executeQuery:sql];
    while( [rs next] )
    {
        rssClass* rss = [[rssClass alloc] init];
        rss.alreadyreadUrl = [rs stringForColumn:@"url"];
        [alreadyreadUrl addObject:rss.alreadyreadUrl];
    }
    [rs close];
    [forRSSDb close];
    
    [_objects setArray:[self loadXML:url]];
    [self.tableView reloadData];

}

- (void)viewDidLoad
{
        kidoku = @"";
        tempUrl = @"";
        tempUrl = @"";
    if (_refreshHeaderView == nil) {
        // 更新ビューのサイズとデリゲートを指定する
        EGORefreshTableHeaderView *view =
        [[EGORefreshTableHeaderView alloc] initWithFrame:
         CGRectMake(
                    0.0f,
                    0.0f - self.tableView.bounds.size.height,
                    self.view.frame.size.width,
                    self.tableView.bounds.size.height
                    )];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    // 最終更新日付を記録
    [_refreshHeaderView refreshLastUpdatedDate];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init] ;
    backButton.title = @"戻る";
    self.navigationItem.backBarButtonItem = backButton;
    
    _objects = [NSMutableArray array];
}

- (void)loadView
{
    [super loadView];
}


/*
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (_refreshHeaderView == nil) {
        // 更新ビューのサイズとデリゲートを指定する
        EGORefreshTableHeaderView *view =
        [[EGORefreshTableHeaderView alloc] initWithFrame:
         CGRectMake(
                    0.0f,
                    0.0f - self.tableView.bounds.size.height,
                    self.view.frame.size.width,
                    self.tableView.bounds.size.height
                    )];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    // 最終更新日付を記録
    [_refreshHeaderView refreshLastUpdatedDate];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init] ;
    backButton.title = @"戻る";
    self.navigationItem.backBarButtonItem = backButton;
    
    _objects = [NSMutableArray array];
    NSLog(@"RSSトピック表示");
    NSLog(@"%@",url);
    
    [_objects setArray:[self loadXML:url]];*/
    /* UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.modalViewController = (DetailViewController *)[[[self.splitViewController.viewControllers lastObject] topViewController];*//*
}*/

// スクロールされたことをライブラリに伝える
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

// テーブルを下に引っ張ったら、ここが呼ばれる。テーブルデータをリロードして3秒後にdoneLoadingTableViewDataを呼んでいる
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    _reloading = YES;
    // 非同期処理
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        // 更新処理など重い処理を書く
        // 今回は2秒待ち
        [NSThread sleepForTimeInterval:2];
        //[self.tableView reloadData];
        // メインスレッドで更新完了処理
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self doneLoadingTableViewData];
        }];
    }];
}

// 更新終了
- (void)doneLoadingTableViewData{
    // 更新終了をライブラリに通知
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}
// 更新状態を返す
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}
// 最終更新日を更新する際の日付の設定
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}

//新たにセルが表示されるとき(スクロールしたときなど)に呼ばれる
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopicCell" forIndexPath:indexPath];
    cell.textLabel.text = _objects[indexPath.row];
    //更新日付を挿入
    dataArrayCount = [dataArray count];
    if(dataArrayCount > 0){
        cell.detailTextLabel.text = dataArray[indexPath.row];
    }
    //XMLに<pubDate>がない場合は空白
    else
        cell.detailTextLabel.text = @"";
        return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// XMLを読み込み解析するメソッド
- (NSMutableArray *)loadXML:(NSString *)urlString {
    // 変数の初期化
    
    titleArray = [NSMutableArray array];
    itemElementCheck = NO;
    titleElementCheck = NO;
    titleText = @"";
    
    dataArray = [NSMutableArray array];
    dataElementCheck = NO;
    dataText = @"";
    
    linkArray = [NSMutableArray array];
    linkElementCheck = NO;
    linkText = @"";
    
    // URLを作成
    NSURL *xmlUrl = [NSURL URLWithString:url];
    
    // URLからパーサーを作成
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlUrl];
    
    // デリゲートをセット
    [parser setDelegate:self];
    
    // XMLを解析
    [parser parse];
    
    // 配列を返す
    return titleArray;
}


// 開始タグの処理
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // item要素のチェック
    if ([elementName isEqualToString:@"item"]) {
        itemElementCheck = YES;
    }
    
    // title要素のチェック
    if (itemElementCheck && [elementName isEqualToString:@"title"]) {
        titleElementCheck = YES;
    } else {
        titleElementCheck = NO;
    }
    // description要素のチェック
    if(itemElementCheck && [elementName isEqualToString:@"pubDate"]){
        dataElementCheck = YES;
    }else if (itemElementCheck && [elementName isEqualToString:@"dc:date"]){
        dataElementCheck = YES;
    }
    else{
        dataElementCheck = NO;
    }
    // link要素のチェック
    if (itemElementCheck && [elementName isEqualToString:@"link"]) {
        linkElementCheck = YES;
    } else {
        linkElementCheck = NO;
    }
}

// 終了タグの処理
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    // item要素のチェック
    if ([elementName isEqualToString:@"item"]) {
        itemElementCheck = NO;
    }
    
    // title要素のチェック
    if ([elementName isEqualToString:@"title"]) {
        NSLog(@"タイトルチェック");
        if (titleElementCheck) {
            //掲載しない記事フラグを初期化　0->広告 1->普通の記事
            unUsedTopic = 0;
            // 広告か否か(PR: の文字列のあるものは記事から除外)
            NSRange range = [titleText rangeOfString:@"PR："];
            NSRange range_2 = [titleText rangeOfString:@"PR:"];
            NSRange range_3 = [titleText rangeOfString:@"AD:"];
            NSRange range_4 = [titleText rangeOfString:@"Info:"];
            if ((range.location == NSNotFound)&&(range_2.location == NSNotFound)&&(range_3.location == NSNotFound)&&(range_4.location == NSNotFound)) {
                unUsedTopic = 1;
                 // 配列titleArrayに追加
                [titleArray addObject:titleText];
            }
        }
        // titleElementCheckをNO、titleTextを空にセット
        titleElementCheck = NO;
        titleText = @"";
    }
    
    // link要素のチェック
    if ([elementName isEqualToString:@"link"]) {
        NSLog(@"リンクチェック");
        if (linkElementCheck) {
            if(unUsedTopic == 1){
                // 配列linkArrayに追加
                [linkArray addObject:linkText];
                if([alreadyreadUrl containsObject:linkText]){
                    kidoku = @"既読";
                }
                //セル内のurlを訪問->戻る
                if([tempUrl isEqualToString: linkText]){
                    //データベースにurlを追加
                    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    documentsDirectory = [paths objectAtIndex:0];
                    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"forRSS.sqlite"];
                    
                    forRSSDb = [FMDatabase databaseWithPath:writableDBPath];
                    if(![forRSSDb open])
                    {
                        NSLog(@"Err %d: %@", [forRSSDb lastErrorCode], [forRSSDb lastErrorMessage]);
                    }
                    else{
                        NSLog(@"データベースオープン");
                    }

                    [forRSSDb setShouldCacheStatements:YES];
                    NSString* insertSQL = [NSString stringWithFormat:@"insert into urlTable values('%@');",tempUrl];
                    FMResultSet* read = [forRSSDb executeQuery:insertSQL];
                    NSLog(@"%@",read);
                    while( [read next] )
                    {
                        rssClass* rss = [[rssClass alloc] init];
                        rss.alreadyreadUrl = [read stringForColumn:@"url"];
                        [alreadyreadUrl addObject:rss.alreadyreadUrl];
                    }
                    NSLog(@"URL%@",alreadyreadUrl);
                    NSLog(@"確認ログ1");
                    kidoku = @"既読";
                    
                    [read close];
                    [forRSSDb close];
                }
            }
        }
        // linkElementCheckをNO、linkTextを空にセット
        linkElementCheck = NO;
        linkText = @"";
    }
    if(dataElementCheck){
        if([elementName isEqualToString:@"pubDate"]){
            if(unUsedTopic == 1){
                //<pubdate>の場合
                dataText = [self convertPubDate:dataText];
                [dataArray addObject:dataText];
            }
        }
        else if ([elementName isEqualToString:@"dc:date"])
        {
            if(unUsedTopic == 1){
                //<dc:date>の場合
                dataText = [self convertdcDate:dataText];
                [dataArray addObject:dataText];
            }
        }
         NSLog(@"確認ログ2");
        dataElementCheck = NO;
        kidoku = @"";
       
        dataText = @"";
    }
}
//<dc:date>2004-06-05T21:54:55+09:00</dc:date>
- (NSString *)convertdcDate:(NSString *)str{
    NSString *step1 = [dataText stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    NSString *step2 = [step1 stringByReplacingOccurrencesOfString:@"T" withString:@"/"];
    NSString *step3 = [step2 substringWithRange:NSMakeRange(0, 19)];
    return dataText = [NSString stringWithFormat:@"%@ 更新 %@",step3,kidoku];
}

//<pubDate>をYYYY/MM/DD HH:MM:SSに変換
- (NSString *)convertPubDate:(NSString *)str{
    
    NSArray *separatedString = [dataText componentsSeparatedByString:@" "];
    // 年を取得
    NSString *year = [separatedString objectAtIndex:3];
    
    // 月の辞書を作る
    // 配列を作るとき、最後の引数にnilを指定しないといけない
    NSArray *monthForKey   =
    [NSArray arrayWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec",nil];
    
    NSArray *monthForValue =
    [NSArray arrayWithObjects:@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", nil];
    
    NSDictionary *monthDict = [NSDictionary dictionaryWithObjects:monthForValue forKeys:monthForKey];
    // 月を取得
    NSString *month = [monthDict objectForKey:[separatedString objectAtIndex:2]];
    
    // 日を取得
    // 一桁のときはゼロパディングする
    NSString *day = [NSString stringWithFormat:@"%02d",[[separatedString objectAtIndex:1] intValue]];
    NSString *hour = [NSString stringWithFormat:@"%@",[separatedString objectAtIndex:4]];

    return  dataText = [NSString stringWithFormat:@"%@/%@/%@/%@ 更新 %@",year,month,day,hour,kidoku];
}

// テキストの取り出し
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // titleテキストの取り出し
    if (titleElementCheck) {
        titleText = [titleText stringByAppendingString:string];
    }
    //dataテキストの取り出し
    if(dataElementCheck){
        dataText = [dataText stringByAppendingString:string];
        NSLog(@"データテキスト%@",dataText);
    }
    
    // linkテキストの取り出し
    if (linkElementCheck) {
        linkText = [linkText stringByAppendingString:string];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *object = linkArray[indexPath.row];
        tempUrl = object;
        DetailViewController *detailViewController = (DetailViewController*)[segue destinationViewController];
        detailViewController.navigationItem.title = titleArray[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}
@end
