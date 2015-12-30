//
//  TopPlacesTableViewController.m
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 21/12/15.
//  Copyright © 2015 Hegyi Hajnalka. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "PlacesPhotoTableViewController.h"
#import "FlickrFetcher.h"

@interface TopPlacesTableViewController ()

@property (nonatomic, strong) NSArray *countryList;
@property (nonatomic, strong) NSArray *placesList;
@property (nonatomic, strong) NSDictionary *placesNameForId;

@end

@implementation TopPlacesTableViewController

- (NSArray *)placesList
{
    if (!_placesList)
    {
        _placesList = [[NSArray alloc] init];
    }
    return _placesList;
}

- (NSArray *)countryList
{
    if (!_countryList)
    {
        _countryList = [[NSArray alloc] init];
    }
    return _countryList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchPlaces];
}

- (void)fetchPlaces
{
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    NSData *jsonResults = [NSData dataWithContentsOfURL:url];
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                        options:0
                                                                          error:NULL];
    
    NSDictionary *detailedPlaces = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
    NSArray *places = [detailedPlaces valueForKeyPath:FLICKR_PLACE_NAME];
    
    NSArray *placeIds = [detailedPlaces valueForKeyPath:FLICKR_PLACE_ID];
    
    NSMutableDictionary *placeIdForPlaceName = [[NSMutableDictionary alloc] init];
    int index = 0;
    for (NSString *placeName in places)
    {
        [placeIdForPlaceName setObject:[placeIds objectAtIndex:index] forKey:placeName];
        index++;
        //NSLog(@"%@", placeName);
    }
    self.placesNameForId = placeIdForPlaceName;
    
    NSMutableDictionary *countryList = [[NSMutableDictionary alloc] init];
    for (NSString *placeName in places) {
        NSArray *placeComponentsArray = [placeName componentsSeparatedByString: @", "];

        NSString *str = [[NSString alloc] initWithString:placeName];
        str = [str stringByReplacingOccurrencesOfString: [NSString stringWithFormat:@", %@",[placeComponentsArray lastObject]]
                                             withString:@""];
        
        NSMutableString *insertedString = [[NSMutableString alloc] initWithString:str];
        if ([countryList objectForKey:[placeComponentsArray lastObject]] != nil) {
            insertedString = [[NSMutableString alloc] initWithString:[countryList objectForKey: [placeComponentsArray lastObject]]];
        
            [insertedString appendString:[NSString stringWithFormat:@" + %@", str]];
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
    //NSLog(@"%@", placesListArray);
    //NSLog(@"%@", countryListArray);
    self.placesList = placesListArray;
    self.countryList = countryListArray;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.placesList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.placesList objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    
    NSString *cellText = [[self.placesList objectAtIndex: indexPath.section] objectAtIndex:indexPath.row];
    NSArray *placesArray = [cellText componentsSeparatedByString: @", "];
    
    NSString *str = [[NSString alloc] initWithString:cellText];
    str = [str stringByReplacingOccurrencesOfString: [NSString stringWithFormat:@"%@, ",[placesArray firstObject]]
                                         withString:@""];
    
    cell.textLabel.text = [placesArray firstObject];
    cell.detailTextLabel.text = str;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.countryList objectAtIndex: section];
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectPlace"])
    {
        PlacesPhotoTableViewController *placesPhotoController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *placeName = [NSString stringWithFormat: @"%@, %@, %@", cell.textLabel.text, cell.detailTextLabel.text, [self.countryList objectAtIndex:indexPath.section]];
        
        //NSLog(@"%@", placeName);
        
        placesPhotoController.placesId = [self.placesNameForId valueForKey:placeName];
    }
}

@end
