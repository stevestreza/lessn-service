//
//  CompressURLServiceAppDelegate.h
//  CompressURLService
//
//  Created by Steve Streza on 9/1/09.
//  Copyright 2009 Ambrosia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CompressURLServiceAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;
-(NSURL *)compressedURLForURL:(NSURL *)url;
@end
