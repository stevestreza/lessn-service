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

-(NSURL *)compressURL:(NSURL *)url atBaseURL:(NSURL *)baseURL{
	NSString *baseURLString = [baseURL absoluteString];
	if([[baseURLString substringFromIndex:[baseURLString length] - 1] isEqualToString:@"/"]){
		baseURLString = [baseURLString substringToIndex:[baseURLString length] - 1];
	}
	
	NSLog(@"Using deprecated method to fetch URL from %@",baseURLString);

	NSURL *newURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/-/?url=%@",baseURLString,[[url absoluteString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	
	//	NSData *htmlData = [newURL resourceDataUsingCache:NO];
	NSData *htmlData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:newURL] returningResponse:nil error:nil];
	NSString *html = [[[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding] autorelease];
	
	if(!html){
		NSLog(@"Cannot download data from URL %@",newURL);
		return nil;
	}
	
	NSString *searchString = @"<input type=\"text\" id=\"url\" value=\"";
	NSRange range = [html rangeOfString:searchString];
	NSUInteger location = range.location + range.length;
	
	NSUInteger endLocation = [html rangeOfString:@"\"" options:0 range:NSMakeRange(location, [html length] - location - 1)].location;
	
	newURL = [NSURL URLWithString:[html substringWithRange:NSMakeRange(location, endLocation-location)]];
	
	return newURL;
}

-(NSURL *)compressURL:(NSURL *)url atBaseURL:(NSURL *)baseURL withAPIKey:(NSString *)apiKey{
	NSString *baseURLString = [baseURL absoluteString];
	if([[baseURLString substringFromIndex:[baseURLString length] - 1] isEqualToString:@"/"]){
		baseURLString = [baseURLString substringToIndex:[baseURLString length] - 1];
	}
	
	NSURL *newURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/-/?api=%@&url=%@",baseURLString, apiKey, [[url absoluteString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	
	//	NSData *htmlData = [newURL resourceDataUsingCache:NO];
	NSData *htmlData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:newURL] returningResponse:nil error:nil];
	NSString *shortURL = [[[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding] autorelease];
	
	return [NSURL URLWithString:shortURL];
}

-(NSURL *)compressedURLForURL:(NSURL *)url{
	NSString *baseURLString = [[NSUserDefaults standardUserDefaults] objectForKey:@"baseURL"];
	if(!baseURLString){
		NSLog(@"%@",NSLocalizedString(@"Error: You need to supply a Lessn or ButteredURLs install via defaults",@""));
		NSLog(@"%@",NSLocalizedString(@"  For a Lessn install at 'http://omgwtf.com/-/', use 'omgwtf.com'", @""));
		NSLog(@"%@",NSLocalizedString(@"    defaults write com.stevestreza.lessnshorten baseURL omgwtf.com",@""));
		return nil;
	}
	
	NSURL *baseURL = [NSURL URLWithString:baseURLString];
	
	NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"apiKey"];
	if(!apiKey){
		NSLog(@"%@",NSLocalizedString(@"Warning: You didn't supply an API key for your Lessn/ButteredURLs installation",@""));
		NSLog(@"%@",NSLocalizedString(@"  This method is deprecated, and uses a hack.",@""));
		NSLog(@"%@",NSLocalizedString(@"  Find your API key in the web app's dashboard, and add it via defaults.",@""));
		NSLog(@"%@",NSLocalizedString(@"    defaults write com.stevestreza.lessnshorten apiKey <<your key>>", @""));
		return [self compressURL:url 
					   atBaseURL:baseURL];
	}else{
		return [self compressURL:url
					   atBaseURL:baseURL
					  withAPIKey:apiKey];
	}
}

@end
