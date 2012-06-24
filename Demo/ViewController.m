//
//  ViewController.m
//  MPFlipViewController
//
//  Created by Mark Pospesel on 6/4/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "ViewController.h"
#import "ContentViewController.h"
#import <QuartzCore/QuartzCore.h>

#define CONTENT_IDENTIFIER @"ContentViewController"
#define FRAME_MARGIN	60
#define MOVIE_MIN		1
#define MOVIE_MAX		3

@interface ViewController ()

@property (assign, nonatomic) int previousIndex;

@end

@implementation ViewController

@synthesize frame = _frame;
@synthesize flipViewController = _flipViewController;
@synthesize corkboard = _corkboard;
@synthesize previousIndex = _previousIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.previousIndex = MOVIE_MIN;
	
	// Configure the page view controller and add it as a child view controller.
	self.flipViewController = [[MPFlipViewController alloc] initWithOrientation:MPFlipViewControllerOrientationHorizontal];
	self.flipViewController.dataSource = self;
	
	// Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
	BOOL hasFrame = self.frame != nil;
	CGRect pageViewRect = self.view.bounds;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		pageViewRect = CGRectInset(pageViewRect, 20 + (hasFrame? FRAME_MARGIN : 0), 20 + (hasFrame? FRAME_MARGIN : 0));
		self.flipViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}
	else
	{
		pageViewRect = CGRectMake((self.view.bounds.size.width - 600)/2, (self.view.bounds.size.height - 600)/2, 600, 600);
		self.flipViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	}
	self.flipViewController.view.frame = pageViewRect;
	[self addChildViewController:self.flipViewController];
	[self.view addSubview:self.flipViewController.view];
	[self.flipViewController didMoveToParentViewController:self];
	
	[self.flipViewController setViewController:[self contentViewWithIndex:self.previousIndex] direction:MPFlipViewControllerDirectionForward animated:NO completion:nil];
	
	// Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
	self.view.gestureRecognizers = self.flipViewController.gestureRecognizers;
	
	[self.corkboard setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Pattern - Corkboard"]]];	
	if (self.frame)
	{
		[self.frame setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Pattern - Apple Wood"]]];
	}
}

- (void)viewDidUnload
{
	[self setCorkboard:nil];
	[self setFrame:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (NSString *)storyboardName
{
	// fetch the appropriate storyboard name depending on platform
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		return @"MainStoryboard_iPhone";
	else
		return @"MainStoryboard_iPad";
}

- (ContentViewController *)contentViewWithIndex:(int)index
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[self storyboardName] bundle:nil];
	ContentViewController *page = [storyboard instantiateViewControllerWithIdentifier:CONTENT_IDENTIFIER];
	page.movieIndex = index;
	page.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	return page;
}

#pragma mark - MPFlipViewControllerDataSource protocol

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	int index = self.previousIndex;
	index--;
	if (index < MOVIE_MIN)
		index = MOVIE_MAX;
	self.previousIndex = index;
	return [self contentViewWithIndex:index];
}

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	int index = self.previousIndex;
	index++;
	if (index > MOVIE_MAX)
		index = MOVIE_MIN;
	self.previousIndex = index;
	return [self contentViewWithIndex:index];	
}

@end
