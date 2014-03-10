//
//  NSObject+CSAPI.h
//  CSMapper
//
//  Created by Marc Ammann on 4/30/12.
//  Copyright (c) 2012 Marc Ammann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSMapper.h"


@interface NSObject (CSAPI)

- (id)initWithDictionary:(NSDictionary *)aDictionary;

- (void)mapAttributesWithDictionary:(NSDictionary *)aDictionary;
- (void)mapAttributesWithDictionary:(NSDictionary *)aDictionary groups:(NSArray *)groups;

+ (NSDictionary *)mappingForEntity:(NSString *)entityKey;

@end
