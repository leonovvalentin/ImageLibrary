//
//  MasterViewController.m
//  imageLibrary2
//
//  Created by admin on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@implementation MasterViewController
{
    NSArray *_imageNameArray;
    __block NSMutableArray *_thumbnailArray;
}

NSInteger const NAVIGATION_BAR_HEIGHT = 44; // ?!

@synthesize detailViewController = _detailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");

        // ?!
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSString* imageFolderPath = [[NSBundle mainBundle] resourcePath];
        imageFolderPath = [imageFolderPath stringByAppendingString:@"/Images"];
        _imageNameArray = [[fileManager contentsOfDirectoryAtPath:imageFolderPath error:nil] retain];
        
        _thumbnailArray = [[NSMutableArray alloc] initWithCapacity:_imageNameArray.count];
        
        UIImage *noImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage.jpg"
                                                                                          ofType:nil
                                                                                     inDirectory:@"auxiliaryImages"]];
        for (NSInteger i=0; i<_imageNameArray.count; i++) {
            [_thumbnailArray addObject:noImage];
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[_imageNameArray objectAtIndex:i]
                                                                                                  ofType:nil
                                                                                             inDirectory:@"Images"]];
            //        CGSize destinationSize = CGSizeMake(image.size.width/10, image.size.height/10);
                CGSize destinationSize = CGSizeMake(32, 48);
                UIGraphicsBeginImageContext(destinationSize);

                [image drawInRect:CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
                UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                [_thumbnailArray replaceObjectAtIndex:i withObject: thumbnail];
                UIGraphicsEndImageContext();
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
    //                NSInteger index = i;
    //                NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:index];
    //                [self update:indexPath];
    //                NSIndexPath *indexPath = [[[NSIndexPath alloc] initWithIndex:index] autorelease];
    //                NSArray *array = [NSArray arrayWithObject:indexPath];
    //                [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
    //                UITableView *tableView = self.tableView;
    //                NSIndexPath *rowPath = [NSIndexPath alloc] 
    //                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:] withRowAnimation:UITableViewRowAnimationRight];
                });
            });
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_imageNameArray release], _imageNameArray = nil;
    [_thumbnailArray release], _thumbnailArray = nil;
    [_detailViewController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _imageNameArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Configure the cell.
    cell.textLabel.text = [_imageNameArray objectAtIndex:indexPath.row];
    cell.imageView.image = [_thumbnailArray objectAtIndex:indexPath.row];
       
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil] autorelease];
        
        [self.detailViewController.view setNeedsDisplay];
        self.detailViewController.imageNames = _imageNameArray;
        self.detailViewController.thumbnailArray = _thumbnailArray;
        self.detailViewController.scrollView.contentSize = CGSizeMake(self.detailViewController.scrollView.frame.size.width * _imageNameArray.count, self.detailViewController.scrollView.bounds.size.height - NAVIGATION_BAR_HEIGHT);
    }
    
    [self.detailViewController showImageNumber:indexPath.row];
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
