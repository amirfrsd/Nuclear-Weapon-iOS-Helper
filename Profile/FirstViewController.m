//
//  FirstViewController.m
//  Profile
//
//  Created by Apple on 7/21/19.
//  Copyright © 2019 Amir Farsad. All rights reserved.
//

#import "FirstViewController.h"
#import "HasteFM.h"
#import "FilesTableViewCell.h"
@interface FirstViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *dataSource;
@end

@implementation FirstViewController
- (void)cykaBlyat {
    NSArray *array = [HasteFM listIPAFilesInDocumentsDirectory];
    self.dataSource = [[NSMutableArray alloc] init];
    if (array.count > 0) {
        for (NSString *appName in array) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,appName];
            [self.dataSource addObject:[HasteFM extractDataFromIPAFileInPath:filePath]];
        }
        [self.tableView reloadData];
    }
}
- (void)mashtiPesar {
    [self cykaBlyat];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mashtiPesar) name:@"bororefresh" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self cykaBlyat];
}
-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Share" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSArray *array = [HasteFM listIPAFilesInDocumentsDirectory];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [[NSString stringWithFormat:@"%@/%@", documentsDirectory,[array objectAtIndex:indexPath.row]] stringByReplacingOccurrencesOfString:@"file:///" withString:@""];
        NSURL *pathFinal = [NSURL fileURLWithPath:filePath];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[pathFinal] applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"%@",[[self.dataSource objectAtIndex:indexPath.row] valueForKey:@"filepath"]);
        NSArray *array = [HasteFM listIPAFilesInDocumentsDirectory];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[array objectAtIndex:indexPath.row]];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        [self cykaBlyat];
    }];
    return @[shareAction,deleteAction];
}
- (IBAction)installBtnAction:(UIButton *)sender {
    
}
- (void)configureCell:(FilesTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.installBtnOutlet.tag = indexPath.row;
    NSData *data = [[NSData alloc]initWithBase64EncodedString:[[self.dataSource objectAtIndex:indexPath.row] valueForKey:@"image"]
                                                      options:NSDataBase64DecodingIgnoreUnknownCharacters];
    cell.fileIconImageView.image = [UIImage imageWithData:data];
    cell.fileNameLabel.text = [[self.dataSource objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.certNameLabel.text = [[self.dataSource objectAtIndex:indexPath.row] valueForKey:@"cert"];
//    cell.expireDateLabel.text = [[self.dataSource objectAtIndex:indexPath.row] valueForKey:@"expire"];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *fileCell = @"filecell";
    FilesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:fileCell];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
@end
