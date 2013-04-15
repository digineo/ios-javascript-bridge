//
//  DatePickingViewController.h
//  selbstauskunft
//
//  Created by Helge on 12.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickingViewControllerDelegate;

@interface DatePickingViewController : UIViewController {
    
    NSDate *currentDate;
    NSDate *minDate;
    NSDate *maxDate;
    NSString *titleText;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UILabel* titleLabel;
}

@property( nonatomic, assign ) id<DatePickingViewControllerDelegate> delegate;
@property( nonatomic, retain ) NSDate *currentDate;
@property( nonatomic, retain ) NSDate *minDate;
@property( nonatomic, retain ) NSDate *maxDate;
@property( nonatomic, retain ) NSString *titleText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDate:(NSDate*)date;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDate:(NSDate*)date withMinimumDate:(NSDate*)dateMin andMaximumDate:(NSDate*)dateMax;

- (IBAction) finishDate:(id)sender;
- (IBAction) cancelDate:(id)sender;
- (IBAction) changedDate:(UIDatePicker*)sender;

@end

@protocol DatePickingViewControllerDelegate <NSObject>

- (void) datePickingViewController:(DatePickingViewController*)controller didFinishWithDate:(NSDate*)date;
- (void) datePickingViewController:(DatePickingViewController*)controller didChangeToDate:(NSDate*)date;
- (void) datePickingViewControllerDidCancel:(DatePickingViewController*)controller;

@end