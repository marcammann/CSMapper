//
//  CSAPIBoolMapper.m
//  CSMapper
//
//  Created by Marc Ammann on 7/26/12.
//  Copyright (c) 2012 Marc Ammann. All rights reserved.
//

#import "CSAPIBoolMapper.h"

@implementation CSAPIBoolMapper

+ (NSNumber *)transformValue:(id)inputValue {
	if ([inputValue isKindOfClass:[NSString class]]) {
		NSString *stringValue = (NSString *)inputValue;
		if ([stringValue isEqualToString:@"on"] ||
			[stringValue isEqualToString:@"true"] ||
			[stringValue isEqualToString:@"1"] ||
			[stringValue isEqualToString:@"TRUE"])
		{
			return [NSNumber numberWithBool:YES];
		}
	} else if ([inputValue isKindOfClass:[NSNumber class]]) {
		return inputValue;
	}
	return [NSNumber numberWithBool:NO];
}

@end
