//
//  CSSubKeyMapper.h
//  TMNGO
//
//  Created by Anton Doudarev on 8/20/12.
//  Copyright (c) 2012 HUGE Inc. All rights reserved.
//

#import "CSSubKeyMapper.h"

@implementation CSSubKeyMapper

+ (id)transformValue:(id)inputValue {
	
	NSString *contentMetaString = [inputValue objectAtIndex:0];
	
	return contentMetaString;
}


@end
