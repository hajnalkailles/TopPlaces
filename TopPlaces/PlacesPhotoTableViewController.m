//
//  PlacesPhotoTableViewController.m
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 28/12/15.
//  Copyright © 2015 Hegyi Hajnalka. All rights reserved.
//

#import "PlacesPhotoTableViewController.h"
#import "ImageViewController.h"
#import "Photo.h"
#import "FlickrFetcher.h"

@implementation PlacesPhotoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setContext:self.context];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"placeTaken.name LIKE %@", self.regionName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"photoDescription"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *photoTitle = photo.title;
    id photoDescription = photo.subtitle;
    
    if (![photoTitle isEqualToString:@""])
    {
        cell.textLabel.text = photoTitle;
        cell.detailTextLabel.text = photoDescription;
    } else if (![photoDescription isEqualToString:@""])
    {
        cell.textLabel.text = photoDescription;
        cell.detailTextLabel.text = @"";
    } else
    {
        cell.textLabel.text = @"Unknown";
        cell.detailTextLabel.text = @"";
    }
    
    if (!photo.thumbnailImage)
    {
        NSURL *fetchURL = [NSURL URLWithString:photo.photoURL];
        
        if (fetchURL) {
            NSURLRequest *request = [NSURLRequest requestWithURL:fetchURL];
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error){
                    if (!error){
                        NSData *jsonResults = [NSData dataWithContentsOfURL: localfile];
                        UIImage *thumbnailImage = [UIImage imageWithData:jsonResults];
                        photo.thumbnailImage = jsonResults;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{cell.imageView.image = thumbnailImage;});
                                                                    }
                                                            }];
            [task resume];
        }
    } else
    {
        cell.imageView.image = [UIImage imageWithData:photo.thumbnailImage];
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
            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [self prepareImageViewController:detail toDisplayPhoto:photo atIndexPath:indexPath];
        }
    }
}

#pragma mark - Navigation

- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(id )photo atIndexPath:(NSIndexPath *)indexPath
{
    Photo *newPhoto = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    ivc.imageURL = [NSURL URLWithString: newPhoto.photoURL];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    ivc.title = cell.textLabel.text;
    ivc.context = self.context;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPicture"])
    {
        ImageViewController *ivc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        ivc.imageURL = [NSURL URLWithString: photo.photoURL];
        ivc.title = cell.textLabel.text;
        ivc.context = self.context;
    }
}

@end
