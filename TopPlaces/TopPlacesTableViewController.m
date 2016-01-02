//
//  TopPlacesTableViewController.m
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 21/12/15.
//  Copyright © 2015 Hegyi Hajnalka. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "PlacesPhotoTableViewController.h"
#import "ImageViewController.h"
#import "FlickrFetcher.h"

@interface TopPlacesTableViewController ()
@property (nonatomic, strong) NSArray *countryList;
@property (nonatomic, strong) NSArray *placeList;
@property (nonatomic, strong) NSDictionary *placesNameDictionary;
@end

@implementation TopPlacesTableViewController

- (NSArray *)countryList
{
    if (!_countryList)
    {
        _countryList = [[NSArray alloc] init];
    }
    return _countryList;
}

- (NSArray *)placeList
{
    if (!_placeList)
    {
        _placeList = [[NSArray alloc] init];
    }
    return _placeList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPlaces];
}

- (void)fetchPlaces
{
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    [self startFetchingPlaces:url];
}

-(void) startFetchingPlaces:(NSURL *)fetchURL
{
    self.countryList = nil;
    self.placeList = nil;
    if (fetchURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:fetchURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error){
                if (!error){
                    if ([request.URL isEqual:fetchURL]) {
                        NSData *jsonResults = [NSData dataWithContentsOfURL: localfile];
                        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
                        
                        NSDictionary *detailedPlaces = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
                        NSArray *places = [detailedPlaces valueForKeyPath:FLICKR_PLACE_NAME];
                        
                        NSArray *placeIds = [detailedPlaces valueForKeyPath:FLICKR_PLACE_ID];
                        
                        NSMutableDictionary *placeIdsByPlaceName = [[NSMutableDictionary alloc] init];
                        int index = 0;
                        for (NSString *placeName in places)
                        {
                            [placeIdsByPlaceName setObject:[placeIds objectAtIndex:index] forKey:placeName];
                            index++;
                        }
                        self.placesNameDictionary = placeIdsByPlaceName;
                        
                        NSMutableDictionary *countryList = [[NSMutableDictionary alloc] init];
                        for (NSString *placeName in places) {
                            NSArray *placeComponentsArray = [placeName componentsSeparatedByString: @", "];
                            
                            NSString *placeString = [[NSString alloc] initWithString:placeName];
                            placeString = [placeString stringByReplacingOccurrencesOfString: [NSString stringWithFormat:@", %@",[placeComponentsArray lastObject]]
                                                                 withString:@""];
                            
                            NSMutableString *insertedString = [[NSMutableString alloc] initWithString:placeString];
                            if ([countryList objectForKey:[placeComponentsArray lastObject]] != nil) {
                                insertedString = [[NSMutableString alloc] initWithString:[countryList objectForKey: [placeComponentsArray lastObject]]];
                                
                                [insertedString appendString:[NSString stringWithFormat:@" + %@", placeString]];
                            }
                            [countryList setObject: insertedString forKey: [placeComponentsArray lastObject]];
                        }
                        
                        NSMutableArray *countryListArray = [[NSMutableArray alloc] init];
                        NSMutableArray *placesListArray = [[NSMutableArray alloc] init];
                        for (id key in countryList)
                        {
                            NSArray *placesArray = [[countryList objectForKey:key] componentsSeparatedByString: @" + "];
                            placesArray = [placesArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                            [placesListArray addObject:placesArray];
                            [countryListArray addObject:key];
                        }
                        self.placeList = placesListArray;
                        self.countryList = countryListArray;
                        
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
    return [self.placeList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.placeList objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    
    NSString *placeName = [[self.placeList objectAtIndex: indexPath.section] objectAtIndex:indexPath.row];
    NSArray *placesArray = [placeName componentsSeparatedByString: @", "];
    
    NSString *placeString = [[NSString alloc] initWithString:placeName];
    placeString = [placeString stringByReplacingOccurrencesOfString: [NSString stringWithFormat:@"%@, ",[placesArray firstObject]]
                                         withString:@""];
    
    cell.textLabel.text = [placesArray firstObject];
    cell.detailTextLabel.text = placeString;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.countryList objectAtIndex: section];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectPlace"])
    {
        PlacesPhotoTableViewController *placesPhotoController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *placeName = [NSString stringWithFormat: @"%@, %@, %@", cell.textLabel.text, cell.detailTextLabel.text, [self.countryList objectAtIndex:indexPath.section]];
        placesPhotoController.placesId = [self.placesNameDictionary valueForKey:placeName];
    }
}

@end
