//
//  CSJoinMapper.m
//  CSMapper
//
//  Created by Marc Ammann on 7/26/12.
//  Copyright (c) 2012 Marc Ammann. All rights reserved.
//

#import "CSJoinMapper.h"

@implementation CSJoinMapper

+ (NSString *)transformValue:(NSArray *)inputValue {
	NSAssert([inputValue isKindOfClass:[NSArray class]], @"Input Value needs to be Array");

	return [inputValue componentsJoinedByString:@":"];
}

@end
