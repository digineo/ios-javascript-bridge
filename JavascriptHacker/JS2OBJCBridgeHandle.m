//
//  JS2OBJCBridgeHandle.m
//  JavascriptHacker
//
//  Created by Helge on 15.04.13.
//  Copyright (c) 2013 Digineo GmbH. All rights reserved.
//

#import "JS2OBJCBridgeHandle.h"

@implementation JS2OBJCBridgeHandle

@synthesize delegate;
@synthesize webView;
@synthesize jsMethod;
@synthesize args;
@synthesize callbackId;

@synthesize wasCalled;
@synthesize hasReturned;
@synthesize resultDelegate;

+ (JS2OBJCBridgeHandle*) handleForWebView:(UIWebView*)_webView withJsMethod:(NSString*)_jsMethod args:(NSArray*)_args withCallbackId:(NSInteger)_callbackId delegate:(id<JS2OBJCBridgeHandleDelegate>)_delegate;
{
    JS2OBJCBridgeHandle *handle = [[JS2OBJCBridgeHandle alloc] init];
    handle.webView = _webView;
    handle.jsMethod = _jsMethod;
    handle.args = _args;
    handle.callbackId = _callbackId;
    handle.wasCalled = NO;
    handle.hasReturned = NO;
    handle.delegate = _delegate;
    return handle;
}

- (void) registerResultDelegate:(id)_delegate;
{
    self.resultDelegate = _delegate;
    if( delegate && [delegate respondsToSelector:@selector(jsBridgeRegisterHandle:)] ) {
        [delegate jsBridgeRegisterHandle:self];
    }
}

- (void) unregisterResultDelegate;
{
    if( delegate && [delegate respondsToSelector:@selector(jsBridgeUnregisterHandle:)] ) {
        [delegate jsBridgeUnregisterHandle:self];
    }
    self.resultDelegate = nil;
}

@end
