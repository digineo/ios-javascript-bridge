//
//  JS2OBJCBridgeHandle.h
//  JavascriptHacker
//
//  Created by Helge on 15.04.13.
//  Copyright (c) 2013 Digineo GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JS2OBJCBridgeHandleDelegate;

@interface JS2OBJCBridgeHandle : NSObject {

    UIWebView *webView;
    NSString *jsMethod;
    NSArray *args;
    NSInteger callbackId;
    BOOL wasCalled;
    BOOL hasReturned;
    id resultDelegate;
}

@property(nonatomic, strong) id resultDelegate;

@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) NSString *jsMethod;
@property(nonatomic, strong) NSArray *args;
@property(nonatomic, assign) NSInteger callbackId;

@property(nonatomic, assign) BOOL wasCalled;
@property(nonatomic, assign) BOOL hasReturned;
@property(nonatomic, assign) id<JS2OBJCBridgeHandleDelegate> delegate;

+ (JS2OBJCBridgeHandle*) handleForWebView:(UIWebView*)_webView withJsMethod:(NSString*)_jsMethod args:(NSArray*)_args withCallbackId:(NSInteger)_callbackId delegate:(id<JS2OBJCBridgeHandleDelegate>)_delegate;


- (void) registerResultDelegate:(id)_delegate;
- (void) unregisterResultDelegate;

@end

@protocol JS2OBJCBridgeHandleDelegate <NSObject>

- (void) jsBridgeRegisterHandle:(JS2OBJCBridgeHandle*)handle;
- (void) jsBridgeUnregisterHandle:(JS2OBJCBridgeHandle*)handle;

@end