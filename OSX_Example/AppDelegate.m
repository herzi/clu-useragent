//
//  AppDelegate.m
//  OSX_Example
//
//  Created by Sven Herzberg on 28.06.15.
//
//

#import "AppDelegate.h"

#import <CLUUserAgent/CLUUserAgent.h>

#import "CLUTestServer.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property CLUTestServer* server;

@end

@implementation AppDelegate

// Insert code here to initialize your application
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.server = [[CLUTestServer alloc] init];
    
    NSError* error = nil;
    NSURL* url = [self.server listenAndReturnError:&error];
    if (!url) {
        @throw [NSException exceptionWithName:@"FIXME" reason:@"Implement!" userInfo:@{NSUnderlyingErrorKey: error}];
    }
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSURLSession* session = [NSURLSession sharedSession];
    
    CLU_WEAKEN(self);
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString* reply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"reply: “%@”", reply);
        
        CLU_STRENGTHEN(self);
        if (self) {
            self.server = nil;
        }
    }] resume];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
