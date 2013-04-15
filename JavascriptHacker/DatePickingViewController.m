//
//  DatePickingViewController.m
//  selbstauskunft
//
//  Created by Helge on 12.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DatePickingViewController.h"


@implementation DatePickingViewController

@synthesize delegate;
@synthesize currentDate;
@synthesize minDate;
@synthesize maxDate;
@synthesize titleText;

#pragma mark -
#pragma mark destruction

- (void)dealloc {
    self.delegate = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark construction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.titleText = nil;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDate:(NSDate*)date {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.currentDate = date;
        self.titleText = nil;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDate:(NSDate*)date withMinimumDate:(NSDate*)dateMin andMaximumDate:(NSDate*)dateMax {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.currentDate = date;
        self.minDate = dateMin;
        self.maxDate = dateMax;
        self.titleText = nil;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [datePicker setMinimumDate:minDate];
    [datePicker setMaximumDate:maxDate];
    [datePicker setDate:currentDate animated:YES];
    [titleLabel setText:titleText];
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) finishDate:(id)sender {
    [delegate datePickingViewController:self didFinishWithDate:currentDate];
}

- (IBAction) cancelDate:(id)sender {
    [delegate datePickingViewControllerDidCancel:self];
}

- (IBAction) changedDate:(UIDatePicker*)sender {
    self.currentDate = sender.date;
    [delegate datePickingViewController:self didChangeToDate:currentDate];
}

@end
