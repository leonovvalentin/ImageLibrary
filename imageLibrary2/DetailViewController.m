//
//  DetailViewController.m
//  imageLibrary2
//
//  Created by admin on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
- (void)configureView;
- (LVImageAndDescription *)imageWithImageNumber:(NSInteger)imageNumber;
//- (LVImageAndDescription *)imageWithImageNumberForAsync:(NSInteger)imageNumber;

@property (retain, nonatomic) LVImageAndDescription *leftImage;
@property (retain, nonatomic) LVImageAndDescription *currentImage;
@property (retain, nonatomic) LVImageAndDescription *rightImage;
@property (retain, nonatomic) UITextView *editedTextView;
@property (retain, nonatomic) NSCache *imageCache;

@end

@implementation DetailViewController
{
    NSArray *_imageNames;
    LVImageAndDescription *_leftImage;
    LVImageAndDescription *_currentImage;
    LVImageAndDescription *_rightImage;
    UITextView *_editedTextView;
    NSInteger _currentImageNumber; // ?!
    Boolean _fromMainPage;
    NSMutableArray *_thumbnailArray; //test
    __block NSCache *_imageCache;
}

@synthesize imageNames = _imageNames;
@synthesize leftImage = _leftImage;
@synthesize currentImage = _currentImage;
@synthesize rightImage = _rightImage;
@synthesize editedTextView = _editedTextView;
@synthesize scrollView = _scrollView;
@synthesize thumbnailArray = _thumbnailArray;
@synthesize imageCache = _imageCache;

- (void)dealloc
{
    self.imageNames = nil;
    self.leftImage = nil;
    self.currentImage = nil;
    self.rightImage = nil;
    self.editedTextView = nil;
    self.imageCache = nil;

    [_scrollView release];
    
    [super dealloc];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_fromMainPage == YES) {
        _fromMainPage = NO;
        return;
    }
    
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);

    if (_currentImageNumber < page) // Листаем справа налево
    {
        [self.leftImage removeFromSuperview];
        self.leftImage = self.currentImage;
        self.currentImage = self.rightImage;
        _currentImageNumber++;
        self.rightImage = [self imageWithImageNumber:_currentImageNumber+1];
        [self.scrollView addSubview:self.rightImage];
        _currentImageNumber = page;
    }
    else if (_currentImageNumber > page) // Листаем слева направо
    {
        [self.rightImage removeFromSuperview];
        self.rightImage = self.currentImage;
        self.currentImage = self.leftImage;
        _currentImageNumber--;
        self.leftImage = [self imageWithImageNumber:_currentImageNumber-1];
        [self.scrollView addSubview:self.leftImage];
        _currentImageNumber = page;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.editedTextView resignFirstResponder];
}

- (void)TextViewTextDidBeginEditing:(NSNotification *)notification
{
    self.editedTextView = notification.object;
}

- (void)keyboardDidShow: (NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSInteger keyboardHeight = (keyboardSize.height < keyboardSize.width) ? keyboardSize.height : keyboardSize.width;
    [UIView animateWithDuration:0.4
                     animations:^(void){
//                         CGRect textViewFrame = self.editedTextView.frame;
//                         self.editedTextView.frame = CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y - keyboardHeight, textViewFrame.size.width, textViewFrame.size.height);
                         CGRect currentFrame = self.editedTextView.superview.frame;
                         self.editedTextView.superview.frame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - keyboardHeight, currentFrame.size.width, currentFrame.size.height);
                     }];
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSInteger keyboardHeight = (keyboardSize.height < keyboardSize.width) ? keyboardSize.height : keyboardSize.width;
    [UIView animateWithDuration:0.4
                     animations:^(void){
//                         CGRect textViewFrame = self.editedTextView.frame;
//                         self.editedTextView.frame = CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y + keyboardHeight, textViewFrame.size.width, textViewFrame.size.height);
                         CGRect currentFrame = self.editedTextView.superview.frame;
                         self.editedTextView.superview.frame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + keyboardHeight, currentFrame.size.width, currentFrame.size.height);
                     }];
}


- (void)showImageNumber:(NSInteger)imageNumber
{
    [self.leftImage removeFromSuperview];
    [self.currentImage removeFromSuperview];
    [self.rightImage removeFromSuperview];
    
    self.currentImage = [self imageWithImageNumber:imageNumber];
    [self.scrollView addSubview:self.currentImage];
    
    if (imageNumber == 0)
    {
        self.leftImage = nil;
        self.rightImage = [self imageWithImageNumber:imageNumber + 1];
    }
    else if (imageNumber == self.imageNames.count-1)
    {
        self.leftImage = [self imageWithImageNumber:imageNumber - 1];
        self.rightImage = nil;
    }
    else
    {
        self.leftImage = [self imageWithImageNumber:imageNumber - 1];
        self.rightImage = [self imageWithImageNumber:imageNumber + 1];
    }
    
    [self.scrollView addSubview:self.leftImage];
    [self.scrollView addSubview:self.rightImage];
    
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * imageNumber, 0);
    
    _currentImageNumber = imageNumber;
}

//- (LVImageAndDescription *)imageWithImageNumberAsync:(NSInteger)imageNumber
//{
//    __block LVImageAndDescription *imageAndDescription = [self.thumbnailArray objectAtIndex:imageNumber];
////    LVImageAndDescription *imageAndDescription;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
////    dispatch_async(dispatch_get_main_queue(), ^{
//        imageAndDescription = [self imageWithImageNumberForAsync:imageNumber];
//    });
//    
//    return imageAndDescription;
//}

//- (LVImageAndDescription *)imageWithImageNumberForAsync:(NSInteger)imageNumber
- (LVImageAndDescription *)imageWithImageNumber:(NSInteger)imageNumber
{
    if (imageNumber < 0 | imageNumber > self.imageNames.count-1)
    {
        return nil;
    }
    
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"ImageAndDescription" owner:self options:nil];
//    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[_imageNames objectAtIndex:imageNumber]
//                                                                                      ofType:nil
//                                                                                 inDirectory:@"Images"]];
    
//    __block UIImage *image = [self.thumbnailArray objectAtIndex:imageNumber];

    BOOL needAsyncImageLoad = NO;
    
    __block UIImage *image = [self.imageCache objectForKey:[NSNumber numberWithInt:imageNumber]];
    if (!image)
    {
        image = [self.thumbnailArray objectAtIndex:imageNumber];
        needAsyncImageLoad = YES;
    }
    
    LVImageAndDescription *imageAndDescription = [nibArray objectAtIndex:0];
    imageAndDescription.imageView.image = image;
    imageAndDescription.descriptionView.text = [_imageNames objectAtIndex:imageNumber];
    [imageAndDescription setFrame:CGRectMake(self.scrollView.frame.size.width * imageNumber, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    [imageAndDescription setBounds:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    [imageAndDescription.imageView setContentMode:UIViewContentModeScaleAspectFit];

    if (needAsyncImageLoad == YES)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            UIImage *largeImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[_imageNames objectAtIndex:imageNumber]
                                                                                                   ofType:nil
                                                                                              inDirectory:@"Images"]];
            CGSize destinationSize = CGSizeMake(320, 480);
            UIGraphicsBeginImageContext(destinationSize);
            [largeImage drawInRect:CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
            UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
            [self.imageCache setObject:thumbnail
                                forKey:[NSNumber numberWithInt:imageNumber]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                imageAndDescription.imageView.image = thumbnail;
            });
            
            UIGraphicsEndImageContext();
        });
    }
    
    return imageAndDescription;
}

#pragma mark - Managing the detail item

//- (void)setDetailItem:(id)newDetailItem
//{
//    if (_detailItem != newDetailItem) {
//        [_detailItem release]; 		
//        _detailItem = [newDetailItem retain]; 
//
//        // Update the view.
//        [self configureView];
//    }
//}

- (void)configureView
{
    // Update the user interface for the detail item.
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
    [self configureView];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(TextViewTextDidBeginEditing:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _fromMainPage = YES;
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    
    _fromMainPage = YES;
//    self.imageCache = [[[NSCache alloc] init] autorelease];

    return self;
}
							
@end
