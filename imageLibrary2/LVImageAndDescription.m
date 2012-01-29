//
//  LVImageAndDescription.m
//  imageLibrary2
//
//  Created by admin on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LVImageAndDescription.h"

@implementation LVImageAndDescription
@synthesize imageView;
@synthesize descriptionView;

- (void)dealloc {
    [imageView release];
    [descriptionView release];
    [super dealloc];
}

@end
