//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "BSForwardGeocoder.h"
#import "NSString+URLEncode.h"


@implementation BSForwardGeocoder
@synthesize delegate;
@synthesize query;
@synthesize results;
@synthesize status;

- (id)initWithDelegate:(id<BSForwardGeocoderDelegate>)aDelegate {
	if ((self = [super init])) {
		delegate = aDelegate;
	}
	return self;
}


- (void)findLocation:(NSString *)searchString {
	// store the query
	self.query = searchString;
	[self performSelectorInBackground:@selector(startGeocoding) withObject:nil];
}

- (void)geocodingSucceded {
    if ([delegate respondsToSelector:@selector(forwardGeocoderFoundLocation:)]) {
        [delegate forwardGeocoderFoundLocation:self];
    }
}


- (void)geocodingFailed:(NSString *)message {
    if ([delegate respondsToSelector:@selector(forwardGeocoderError::)]) {
        [delegate forwardGeocoderError:self errorMessage:message];
    }
}


- (void)startGeocoding {
	// Create the URL for the Google API request
	NSURL *mapsURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.google.com/maps/api/geocode/xml?address=%@&sensor=false", [query URLEncodedString]]];

	// Run the KML parser
	NSError *parseError = nil;
	BSGoogleV3KmlParser *parser = [[[BSGoogleV3KmlParser alloc] init] autorelease];
	[parser parseXMLFileAtURL:mapsURL parseError:&parseError ignoreAddressComponents:NO];
	status = parser.statusCode;

	// If the query was successfull we store the array with results
	if (parser.statusCode == G_GEO_SUCCESS) {
		self.results = parser.results;
	}
	
	if (parseError != nil) {
		[self performSelectorOnMainThread:@selector(geocodingFailed:) withObject:[parseError localizedDescription] waitUntilDone:NO];
	} else {
		[self performSelectorOnMainThread:@selector(geocodingSucceded) withObject:nil waitUntilDone:NO];
	}
}


- (void)dealloc {
    [query release];
	[results release];
	[super dealloc];
}
@end
