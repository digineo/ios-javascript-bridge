//
//  ViewController.h
//  JavascriptHacker
//
//  Created by Helge on 09.04.13.
//  Copyright (c) 2013 Digineo GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickingViewController.h"
#import "JS2OBJCBridgeHandle.h"

@interface JS2OBJCViewController : UIViewController <UIWebViewDelegate,DatePickingViewControllerDelegate,JS2OBJCBridgeHandleDelegate,UIAlertViewDelegate> {

    IBOutlet UIWebView *myWebView;
    IBOutlet UIButton *actionButton;
    NSMutableArray *pendingBridgeHandles;
}


@property( nonatomic, strong ) UIWebView *myWebView;
@property( nonatomic, strong ) UIButton *actionButton;
@property( nonatomic, strong ) NSMutableArray *pendingBridgeHandles;

- (IBAction) actionSendAlert:(id)sender;

@end
