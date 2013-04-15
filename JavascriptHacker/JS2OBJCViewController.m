//
//  ViewController.m
//  JavascriptHacker
//
//  Created by Helge on 09.04.13.
//  Copyright (c) 2013 Digineo GmbH. All rights reserved.
//

#import "JS2OBJCViewController.h"
#import <objc/message.h>

#define ALERT_TAG_ALERT         100
#define ALERT_TAG_UPLOAD        101

@implementation JS2OBJCViewController

@synthesize myWebView;
@synthesize actionButton;
@synthesize pendingBridgeHandles;

#pragma mark - view handling

- (void)viewDidLoad;
{
    [super viewDidLoad];
    myWebView.delegate = self;
    NSURL *testHtmlUrl = nil;
    if( NO ) {
        testHtmlUrl = [NSURL URLWithString:@"http://test%40example.com:foobar@selbstauskunft.staging.digineo.de/app/requests/1.html"];
    }
    else {
        testHtmlUrl = [[NSBundle mainBundle] URLForResource:@"Website" withExtension:@".html"];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:testHtmlUrl];
    [myWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
}

#pragma mark - user actions (some example call via bridge into webview)

- (IBAction) actionSendAlert:(id)sender;
{
    NSString *alertMessage = @"This is a message from Obj-C.";
    NSString *javaScriptCall = [NSString stringWithFormat:@"Web_AlertWithParams('%@')", alertMessage];
    [myWebView stringByEvaluatingJavaScriptFromString:javaScriptCall];
}

#pragma mark - bridged example methods

- (void) testChangeColorWithBridgeHandle:(JS2OBJCBridgeHandle*)handle;
{
    NSArray *args = handle.args;
    if( [args count] != 3 ) {
        NSLog( @"testChangeColor needs exactly 3 arguments: RED, GREEN, BLUE" );
        return;
    }
    NSNumber *red = (NSNumber*)[args objectAtIndex:0];
    NSNumber *green = (NSNumber*)[args objectAtIndex:1];
    NSNumber *blue = (NSNumber*)[args objectAtIndex:2];
    self.view.backgroundColor = [UIColor colorWithRed:red.floatValue green:green.floatValue blue:blue.floatValue alpha:0.5];
}

- (void) testAnimateButtonWithBridgeHandle:(JS2OBJCBridgeHandle*)handle;
{
    [UIView animateWithDuration:0.3 animations:^{
        actionButton.transform = CGAffineTransformMakeRotation( 0.9 );
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            actionButton.transform = CGAffineTransformMakeRotation( -0.9 );
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                actionButton.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                //
            }];
        }];
    }];
}

- (void) sakDatepickerWithBridgeHandle:(JS2OBJCBridgeHandle*)handle;
{
    NSArray *args = handle.args;
    if( [args count] != 3 ) {
        NSLog( @"sakDatepicker needs exactly 3 arguments: TITLE, MINDATE, MAXDATE" );
        return;
    }
    
    NSString *dateMinString = [args objectAtIndex:1];
    NSString *dateMaxString = [args objectAtIndex:2];
    NSDate *dateMin = nil;
    NSDate *dateMax = nil;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    @try {
        dateMin = [df dateFromString:dateMinString];
        dateMax = [df dateFromString:dateMaxString];
    }
    @catch (NSException *exception) {
        dateMin = [[NSDate date] dateByAddingTimeInterval:-20000000];
        dateMax = [NSDate date];
    }
    
    DatePickingViewController *controller = [[DatePickingViewController alloc] initWithNibName:@"DatePickingViewController" bundle:nil andDate:dateMax withMinimumDate:dateMin andMaximumDate:dateMax];
    controller.titleText = [args objectAtIndex:0];
    controller.delegate = self;
    [handle registerResultDelegate:controller];
    [self presentViewController:controller animated:YES completion:^{
    }];
}

- (void) sakAlertWithBridgeHandle:(JS2OBJCBridgeHandle*)handle;
{
    if( [handle.args count] != 2 ) {
        NSLog( @"sakAlert needs exactly 2 arguments: TITLE, MESSAGE" );
        return;
    }
    NSArray *args = handle.args;
    NSString *title = [args objectAtIndex:0];
    NSString *message = [args objectAtIndex:1];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    alert.tag = ALERT_TAG_ALERT;
    [handle registerResultDelegate:alert];
    [alert show];
}

- (void) sakIdcopyUploaderWithBridgeHandle:(JS2OBJCBridgeHandle*)handle;
{
    if( [handle.args count] != 0 ) {
        NSLog( @"sakAlert needs no further arguments." );
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ID Card" message:@"ID Card Kopie hochgeladen?" delegate:self cancelButtonTitle:@"Nein" otherButtonTitles:@"Ja", nil];
    alert.tag = ALERT_TAG_UPLOAD;
    [handle registerResultDelegate:alert];
    [alert show];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    
    NSString *requestString = [[[request URL] absoluteString] copy];
    
    // FILTER OUT JS-BRIDGE-CALLS via PROTOCOL
    if ([requestString hasPrefix:@"js-frame:"]) {
        NSLog( @"iframe-request: %@",requestString );
        
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        
        NSString *function = (NSString*)[components objectAtIndex:1];
        NSInteger callbackId = [((NSString*)[components objectAtIndex:2]) integerValue];
        NSString *argsAsString = [(NSString*)[components objectAtIndex:3]
                                  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *args = [NSJSONSerialization JSONObjectWithData:[argsAsString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];

        JS2OBJCBridgeHandle *jsHandle = [JS2OBJCBridgeHandle handleForWebView:webView withJsMethod:function args:args withCallbackId:callbackId delegate:self];
        [self jsBridgeCallWithHandle:jsHandle];
        
        return NO;
    }
    else {
        NSLog( @"request: %@", requestString ? requestString : @"[NIL]" );
    }
    return YES;
}

// DISPLAY ERROR IN BRIDGING
- (void)jsBridgeDisplayErrorWithMessage:(NSString*)message {
    NSString *title = @"Bridgefehler (JS-2-Obj-C)";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

// SELECT AND EXECUTE A JS-BRIDGE CALL
- (void) jsBridgeCallWithHandle:(JS2OBJCBridgeHandle*)handle;
{
    handle.wasCalled = YES;
    NSMutableDictionary *definedBridgeMethods = [NSMutableDictionary dictionary];
    
    // SETUP SUPPORTED JS-BRIDGE-CALLS
    NSArray *supportedMethodNames = [NSArray arrayWithObjects:@"sakAlert",
                                     @"sakIdcopyUploader",
                                     @"sakDatepicker",
                                     @"testDatepicker",
                                     @"testChangeColor",
                                     @"testAnimateButton", nil];
    NSString *currentObjcMethodName = nil;
    for( NSString* currentJsMethodName in supportedMethodNames ) {
        currentObjcMethodName = [NSString stringWithFormat:@"%@WithBridgeHandle:", currentJsMethodName];
        [definedBridgeMethods setObject:currentObjcMethodName forKey:currentJsMethodName];
    }
    
    NSArray *jsMethodNames = [definedBridgeMethods allKeys];
    for( NSString* currentJsMethodName in jsMethodNames ) {
        if( [handle.jsMethod isEqualToString:currentJsMethodName] ) {
            NSString *objcMethodSelectorName = [definedBridgeMethods objectForKey:currentJsMethodName];
            SEL objcMethodSelector = NSSelectorFromString(objcMethodSelectorName);
            NSLog( @"JSBRIDGE: FOUND DEFINED SELECTOR FOR JS-METHOD '%@'", currentJsMethodName );
            
            if( [self respondsToSelector:objcMethodSelector] ) {
                NSLog( @"JSBRIDGE: CALLING OBJC-METHOD WITH NAME '%@'", objcMethodSelectorName );
                objc_msgSend( self, objcMethodSelector, handle );
            }
            else {
                NSLog( @"JSBRIDGE: OBJC-METHOD NOT IMPLEMENTED WITH NAME '%@'", objcMethodSelectorName );
                [self jsBridgeDisplayErrorWithMessage:[NSString stringWithFormat:@"Obj-C-Methode nicht implementiert: %@", objcMethodSelectorName]];
            }
            return;
        }
    }
    NSLog( @"JSBRIDGE: JS-METHOD NOT KNOWN AT ALL WITH NAME '%@'", handle.jsMethod );
    [self jsBridgeDisplayErrorWithMessage:[NSString stringWithFormat:@"JS-Methode nicht bekannt: %@", handle.jsMethod]];
}

// REGISTER A HANDLE
- (void) jsBridgeRegisterHandle:(JS2OBJCBridgeHandle*)handle;
{
    if( !pendingBridgeHandles) {
        self.pendingBridgeHandles = [NSMutableArray array];
    }
    [pendingBridgeHandles addObject:handle];
}

// UNREGISTER A HANDLE
- (void) jsBridgeUnregisterHandle:(JS2OBJCBridgeHandle*)handle;
{
    if( !pendingBridgeHandles) return;
    if( [pendingBridgeHandles containsObject:handle] ) {
        [pendingBridgeHandles removeObject:handle];
    }
}

// GET A REGISTERED HANDLE
- (JS2OBJCBridgeHandle*)jsBridgeHandleForResultDelegate:(id)resultDelegate;
{
    if( !pendingBridgeHandles) return nil;
    for( JS2OBJCBridgeHandle *currentHandle in pendingBridgeHandles ) {
        if( currentHandle.resultDelegate == resultDelegate ) {
            return currentHandle;
        }
    }
    return nil;
}

// SEND BACK RESULTS OVER JS-BRIDGE
- (void)jsBridgeReturnResultForHandle:(JS2OBJCBridgeHandle *)handle andArgs:(id)arg, ...;
{
    va_list argsList = nil;
    NSMutableArray *resultArray = [NSMutableArray array];
    
    if( arg != nil ){
        [resultArray addObject:arg];
        va_start( argsList, arg );
        arg = va_arg( argsList, id );
        while( arg != nil ) {

            if( [arg isKindOfClass:[NSString class]] ) {
                [resultArray addObject:arg];
            }
            if( [arg isKindOfClass:[NSDate class]] ) {
                NSString *dateString = [NSString stringWithFormat:@"%@", (NSDate*)arg];
                [resultArray addObject:dateString];
            }
            else {
                [resultArray addObject:@""];
            }
            
            arg = va_arg( argsList, id );
        }
        va_end( argsList );
    }

    NSInteger callbackId = handle.callbackId;
    if( callbackId == 0 ) {
        NSLog( @"JSBRIDGE: HANDLE NOT RETURNING PROPERLY; callbackId = %i for JS-METHOD '%@'", callbackId, handle.jsMethod );
        return;
    }
    NSLog( @"JSBRIDGE: RETURNING RESULT WITH callbackId = %i for JS-METHOD '%@'", callbackId, handle.jsMethod );
   
    
    NSError *error = nil;
    NSData *resultJsonData = [NSJSONSerialization dataWithJSONObject:resultArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultJsonArrayString = [[NSString alloc] initWithData:resultJsonData encoding:NSUTF8StringEncoding];
    NSLog( @"JSBRIDGE: SENDS JSON OVER BRIDGE '%@'", resultJsonArrayString );
    
    [self performSelector:@selector(jsBridgeReturnResultAfterDelay:) withObject:[NSString stringWithFormat:@"NativeBridge.resultForCallback(%d,%@);",callbackId,resultJsonArrayString] afterDelay:0];
    // REMOVE FROM PENDING
    [handle unregisterResultDelegate];
}

-(void)jsBridgeReturnResultAfterDelay:(NSString*)str;
{
    NSLog( @"JSBRIDGE: CALLING JS IN WEBVIEW" );
    [myWebView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:str waitUntilDone:NO];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    NSLog( @"JSBRIDGE: FINISHED LOADING" );
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    NSLog( @"JSBRIDGE: STARTED LOADING" );
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog( @"JSBRIDGE: FAILED LOADING WITH ERROR %@", error ? error : @"[NO ERROR INFO]" );
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    JS2OBJCBridgeHandle *handle = [self jsBridgeHandleForResultDelegate:alertView];
    
    switch (alertView.tag) {
        case ALERT_TAG_ALERT:
            [self jsBridgeReturnResultForHandle:handle andArgs:[NSNumber numberWithBool:YES],nil];
            break;
            
        case ALERT_TAG_UPLOAD:
            if( buttonIndex == alertView.firstOtherButtonIndex ) {
                [self jsBridgeReturnResultForHandle:handle andArgs:[NSNumber numberWithBool:YES],nil];
            }
            else {
                [self jsBridgeReturnResultForHandle:handle andArgs:[NSNumber numberWithBool:NO],nil];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - DatePickingViewControllerDelegate

- (void) datePickingViewController:(DatePickingViewController*)controller didFinishWithDate:(NSDate*)date;
{
    [self dismissViewControllerAnimated:YES completion:^{
        JS2OBJCBridgeHandle *handle = [self jsBridgeHandleForResultDelegate:controller];
        NSString *dateString = [NSString stringWithFormat:@"%@", date];
        [self jsBridgeReturnResultForHandle:handle andArgs:dateString,nil];
    }];
}

- (void) datePickingViewController:(DatePickingViewController*)controller didChangeToDate:(NSDate*)date;
{
}

- (void) datePickingViewControllerDidCancel:(DatePickingViewController*)controller;
{
    [self dismissViewControllerAnimated:YES completion:^{
        JS2OBJCBridgeHandle *handle = [self jsBridgeHandleForResultDelegate:controller];
        [self jsBridgeReturnResultForHandle:handle andArgs:nil];
    }];
}

@end
