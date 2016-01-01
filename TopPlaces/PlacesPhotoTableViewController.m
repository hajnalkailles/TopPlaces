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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchPhotosInPlaces];
}

- (void) fetchPhotosInPlaces {
    //NSLog(@"%@", self.placesId);
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
                        NSDictionary *photosInPlace = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                      options:0
                                                                                        error:NULL];
                        
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.photoList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        ivc.imageURL = [FlickrFetcher URLforPhoto:[self.photoList objectAtIndex: indexPath.row] format:FlickrPhotoFormatOriginal];
        ivc.title = cell.textLabel.text;
    }
}


@end
