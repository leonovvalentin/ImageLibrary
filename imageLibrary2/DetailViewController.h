//
//  DetailViewController.h
//  imageLibrary2
//
//  Created by admin on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LVImageAndDescription.h"

@interface DetailViewController : UIViewController <UIScrollViewDelegate>

- (void) showImageNumber:(NSInteger)imageNumber;

@property (retain, nonatomic) NSMutableArray *thumbnailArray; //test
@property (retain, nonatomic) NSArray *imageNames;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@end
