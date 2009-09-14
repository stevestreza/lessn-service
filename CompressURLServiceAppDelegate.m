//
//  CompressURLServiceAppDelegate.m
//  CompressURLService
//
//  Created by Steve Streza on 9/1/09.
//  Copyright 2009 Ambrosia Software. All rights reserved.
//

#import "CompressURLServiceAppDelegate.h"

@implementation CompressURLServiceAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	[NSApp setServicesProvider:self];
}

-(void)compressedURL:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error{
	// Test for URLs and strings on the pasteboard.
	NSArray *classes = [NSArray arrayWithObjects:[NSURL class], [NSString class], nil];
	NSDictionary *options = [NSDictionary dictionary];
	
	if (![pboard canReadObjectForClasses:classes options:options]) {
		*error = @"Couldn't shorten URLs";
		return;
	}
	
	// Get and encrypt the string.
	NSURL *url = (NSURL *)[pboard stringForType:NSPasteboardTypeString];
	if([url isKindOfClass:[NSString class]]){
		url = [NSURL URLWithString:(NSString *)url];
	}
	
	NSURL *newURL = [self compressedURLForURL:url];
	if (!newURL) {
		*error = @"Couldn't shorten URLs";
		return;
	}
	
	// Write the encrypted string onto the pasteboard.
	[pboard clearContents];
	[pboard writeObjects:[NSArray arrayWithObject:newURL]];
}

-(NSURL *)compressedURLForURL:(NSURL *)url{
	NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"baseURL"];
	if(!baseURL){
		NSLog(@"%@",NSLocalizedString(@"Error: You need to supply a Lessn install via defaults",nil));
		NSLog(@"%@",NSLocalizedString(@"For a Lessn install at 'http://omgwtf.com/-/', use 'omgwtf.com'", nil));
		NSLog(@"%@",NSLocalizedString(@"   defaults write com.stevestreza.lessnshorten baseURL omgwtf.com",nil));
		return nil;
	}
	
	if([[baseURL substringFromIndex:[baseURL length] - 1] isEqualToString:@"/"]){
		baseURL = [baseURL substringToIndex:[baseURL length] - 1];
	}
	
	NSURL *newURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/-/?url=%@",baseURL,[[url absoluteString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	
//	NSData *htmlData = [newURL resourceDataUsingCache:NO];
	NSData *htmlData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:newURL] returningResponse:nil error:nil];
	NSString *html = [[[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding] autorelease];
	
	if(!html){
		NSLog(@"Cannot download data from URL %@",newURL);
		return nil;
	}

#warning I totally do not need to be doing this much work. Damn you, Lessn.
	NSString *searchString = @"<input type=\"text\" id=\"url\" value=\"";
	NSRange range = [html rangeOfString:searchString];
	NSUInteger location = range.location + range.length;
	
	NSUInteger endLocation = [html rangeOfString:@"\"" options:0 range:NSMakeRange(location, [html length] - location - 1)].location;
	
	newURL = [NSURL URLWithString:[html substringWithRange:NSMakeRange(location, endLocation-location)]];
	
	return newURL;
}

@end
