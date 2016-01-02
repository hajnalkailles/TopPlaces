//
//  PlacesPhotoTableViewController.m
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 28/12/15.
//  Copyright © 2015 Hegyi Hajnalka. All rights reserved.
//

#import "PlacesPhotoTableViewController.h"
#import "ImageViewController.h"
#import "FlickrFetcher.h"

@interface PlacesPhotoTableViewController ()
@property (nonatomic, strong) NSArray *photoList;
@end

@implementation PlacesPhotoTableViewController

- (NSArray *) photoList
{
    if (!_photoList)
    {
        _photoList = [[NSArray alloc] init];
    }
    return _photoList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPhotosInPlaces];
}

- (void) fetchPhotosInPlaces
{
    NSURL *url = [FlickrFetcher URLforPhotosInPlace:self.placesId maxResults:50];
    [self startFetchingImages:url];
}

-(void) startFetchingImages:(NSURL *)fetchURL
{
    self.photoList = nil;
    if (fetchURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:fetchURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error){
                if (!error){
                    if ([request.URL isEqual:fetchURL]) {
                        NSData *jsonResults = [NSData dataWithContentsOfURL: localfile];
                        NSDictionary *photosInPlace = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
                        
                        NSMutableArray *photos = [photosInPlace valueForKeyPath:@"photos.photo"];
                        NSMutableArray *photosToKeep = [[NSMutableArray alloc] init];
                        for (id photo in photos)
                        {
                            NSURL *photoUrl = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatOriginal];
                            if (photoUrl)
                            {
                                [photosToKeep addObject:photo];
                            }
                        }
                        self.photoList = photosToKeep;
                        dispatch_async(dispatch_get_main_queue(), ^{[self.tableView reloadData];});
                    }
                }
            }];
        [task resume];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoDescription" forIndexPath:indexPath];
    
    NSString *photoTitle = [[self.photoList objectAtIndex:indexPath.row] valueForKey: FLICKR_PHOTO_TITLE];
    id photoDescription = [[self.photoList objectAtIndex:indexPath.row] valueForKey:@"description"];
    id descriptionContent = [photoDescription valueForKey:@"_content"];
    
    if (![photoTitle isEqualToString:@""])
    {
        cell.textLabel.text = photoTitle;
        cell.detailTextLabel.text = descriptionContent;
    } else if (![descriptionContent isEqualToString:@""])
    {
        cell.textLabel.text = descriptionContent;
        cell.detailTextLabel.text = @"";
    } else
    {
        cell.textLabel.text = @"Unknown";
        cell.detailTextLabel.text = @"";
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
            [self prepareImageViewController:detail toDisplayPhoto:[self.photoList objectAtIndex:indexPath.row] atIndexPath:indexPath];
        }
    }
}

#pragma mark - Navigation

- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(id )photo atIndexPath:(NSIndexPath *)indexPath
{
    ivc.photoDictionary = [self.photoList objectAtIndex:indexPath.row];
    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatOriginal];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    ivc.title = cell.textLabel.text;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPicture"])
    {
        ImageViewController *ivc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        ivc.photoDictionary = [self.photoList objectAtIndex: indexPath.row];
        ivc.imageURL = [FlickrFetcher URLforPhoto:[self.photoList objectAtIndex: indexPath.row] format:FlickrPhotoFormatOriginal];
        ivc.title = cell.textLabel.text;
    }
}

@end
