//
//  MasterViewController.m
//  RSSViewer
//
//  Created by 佐藤　史渉 on 2013/11/15.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import "MasterViewController.h"
#import "RSSTopicViewController.h"
#import "rssClass.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
    //タイトルを保存
    NSString *xmlTitle;
    //タップしたセルのurlを格納
    NSString *mainUrl;
}
@end

@implementation MasterViewController

NSArray *paths;
NSString *documentsDirectory ;
NSString *writableDBPath ;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)loadView
{
    [super loadView];
    _nameArray = [[NSMutableArray alloc] init];
    _urlArray = [[NSMutableArray alloc] init];
    _iconArray = [[NSMutableArray alloc] init];
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"forRSS.sqlite"];
    
    FMDatabase* speakerDb = [FMDatabase databaseWithPath:writableDBPath];
    if(![speakerDb open])
    {
        NSLog(@"Err %d: %@", [speakerDb lastErrorCode], [speakerDb lastErrorMessage]);
    }
    
    [speakerDb setShouldCacheStatements:YES];
    
    NSString* sql = @"SELECT * FROM rss_Site ;";
    FMResultSet* rs = [speakerDb executeQuery:sql];
    while( [rs next] )
    {
        rssClass* rss = [[rssClass alloc] init];
        rss.title = [rs stringForColumn:@"name"];
        rss.weburl = [rs stringForColumn:@"url"];
        rss.icon = [rs stringForColumn:@"icon"];
        [_nameArray addObject:rss.title];
        [_urlArray addObject:rss.weburl];
        [_iconArray addObject:rss.icon];
    }
    //NSLog(@"%@",_nameArray);
    [rs close];
    [speakerDb close];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    NSLog(@"マスタービュートピック表示");
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    //self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return _objects.count;
    return _nameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *iconName = [_iconArray objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"RssCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil){
        cell = [[ UITableViewCell alloc ] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_nameArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [_urlArray objectAtIndex:indexPath.row];
    cell.imageView.image =  [ UIImage imageNamed:iconName];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
       
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRSS"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        xmlTitle = _nameArray[indexPath.row];
        mainUrl = _urlArray[indexPath.row];
        NSLog(@"セグエ");
        NSLog(@"%@",mainUrl);
        RSSTopicViewController *rssViewController = (RSSTopicViewController*)[segue destinationViewController];
        rssViewController.url = mainUrl;
        NSString *str =
        [NSString stringWithFormat:@"%@の記事一覧", xmlTitle];
        rssViewController.navigationItem.title = str;
    }
}


@end
