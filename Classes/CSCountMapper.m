//
//  CSCountMapper.m
//  CSMapper
//
//  Created by Marc Ammann on 7/26/12.
//  Copyright (c) 2012 Marc Ammann. All rights reserved.
//

#import "CSCountMapper.h"

@implementation CSCountMapper

+ (NSNumber *)transformValue:(NSArray *)inputValue {
	NSAssert([inputValue isKindOfClass:[NSArray class]], @"Input Value needs to be Array");
	
	return [NSNumber numberWithInt:[inputValue count]];
}

@end
