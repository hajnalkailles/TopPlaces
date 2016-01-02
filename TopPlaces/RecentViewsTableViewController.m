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
#import "FlickrFetcher.h"

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

- (void)viewDidLoad
{
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recentImages count];
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recentPicture" forIndexPath:indexPath];
    
    NSString *photoTitle = [[self.recentImages objectAtIndex:indexPath.row] valueForKey: FLICKR_PHOTO_TITLE];
    id photoDescription = [[self.recentImages objectAtIndex:indexPath.row] valueForKey:@"description"];
    id descriptionContent = [photoDescription valueForKey:@"_content"];
    
    if (![photoTitle isEqualToString:@""])
    {
        cell.textLabel.text = photoTitle;
    } else if (![descriptionContent isEqualToString:@""])
    {
        cell.textLabel.text = descriptionContent;
    } else
    {
        cell.textLabel.text = @"Unknown";
    }
 
    return cell;
 }

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]])
    {
        detail = [detail topViewController];
        if ([detail isKindOfClass:[ImageViewController class]])
        {
            [self prepareImageViewController:detail toDisplayPhoto:[FlickrFetcher URLforPhoto:[self.recentImages objectAtIndex: indexPath.row] format:FlickrPhotoFormatOriginal] atIndexPath:indexPath];
        }
    }
}

#pragma mark - Navigation

- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(NSURL *)photo atIndexPath:(NSIndexPath *)indexPath
{
    ivc.photoDictionary = [self.recentImages objectAtIndex:indexPath.row];
    ivc.imageURL = photo;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    ivc.title = cell.textLabel.text;
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if ([segue.identifier isEqualToString:@"showPicture"])
     {
         ImageViewController *ivc = [segue destinationViewController];
         NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
         UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
         ivc.photoDictionary = [self.recentImages objectAtIndex: indexPath.row];
         ivc.imageURL = [FlickrFetcher URLforPhoto:[self.recentImages objectAtIndex: indexPath.row] format:FlickrPhotoFormatOriginal];
         ivc.title = cell.textLabel.text;
     }
 }

@end
