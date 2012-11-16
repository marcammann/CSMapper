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
	if (![inputValue isKindOfClass:[NSArray class]]) {
#ifdef DEBUG
		LOG_G(@"[CSCountMapper Mapping Error]: %@ is not of type NSArray", inputValue);
#endif
		return nil;
	}
	
	return [NSNumber numberWithInt:[inputValue count]];
}

@end
