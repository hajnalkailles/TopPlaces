//
//  RecentViewsTableViewController.m
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 21/12/15.
//  Copyright © 2015 Hegyi Hajnalka. All rights reserved.
//

#import "RecentViewsTableViewController.h"
#import "ImageViewController.h"
#import "UserDefaultsSaver.h"

@interface RecentViewsTableViewController ()

@property (nonatomic, strong) NSArray *recentImages;

@end

@implementation RecentViewsTableViewController

- (NSArray *)recentImages
{
    if (!_recentImages)
    {
        _recentImages = [[NSArray alloc] init];
    }
    return _recentImages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recentImages = [UserDefaultsSaver getRecentImages];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.recentImages = [UserDefaultsSaver getRecentImages];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.recentImages count];
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recentPicture" forIndexPath:indexPath];
     cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.recentImages objectAtIndex:indexPath.row]];
 
     return cell;
 }


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"showPicture"])
     {
         ImageViewController *ivc = [segue destinationViewController];
         NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
         UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
         ivc.imageURL = [self.recentImages objectAtIndex:indexPath.row];
         ivc.title = cell.textLabel.text;
     }
 }


@end
