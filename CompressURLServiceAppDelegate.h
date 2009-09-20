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

//requires Lessn 1.0.5+ or ButteredURLs 1.1.1+
-(NSURL *)compressURL:(NSURL *)url
			atBaseURL:(NSURL *)baseURL 
		   withAPIKey:(NSString *)apiKey;

//deprecated method
-(NSURL *)compressURL:(NSURL *)url 
			atBaseURL:(NSURL *)baseURL;
@end
