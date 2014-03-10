//
//  NSObject+CSAPI.m
//  CSMapper
//
//  Created by Marc Ammann on 4/30/12.
//  Copyright (c) 2012 Marc Ammann. All rights reserved.
//

#import "NSObject+CSAPI.h"
#import <objc/runtime.h>
#import <objc/message.h>

#import "CSAPIBoolMapper.h"
#import "CSJoinMapper.h"
#import "CSCountMapper.h"


static NSString * const CSMappingParentKey = @"__parent__";
static NSString * const CSMappingKeyKey = @"key";
static NSString * const CSMappingClassKey = @"type";
static NSString * const CSMappingGroupsKey = @"groups";
static NSString * const CSMappingArraySubTypeKey = @"array_subtype";
static NSString * const CSMappingMapperKey = @"mapper";
static NSString * const CSMappingDefaultKey = @"default";

@implementation NSObject (CSAPI)

// Auto-mapped Initializer
- (id)initWithDictionary:(NSDictionary *)aDictionary {
    self = [self init];
    if (self) {
        [self mapAttributesWithDictionary:aDictionary];
    }
    return  self;
}

/**
 Maps data from aDictionary according to a given .plist file whose name matches
 the name of the class.
 
 There are 3 different options to this. You can just specify the attribute "key"
 inside the plist per attribute. Which is the mapping.
 
 Example:
 testBlah: {
 key: test_key
 }
 
 would map aDictionary['test_key'] to testBlah.
 
 If you specify 'type' as well, a given type will be enforced.
 There are built in types and custom types, like CSBool which serve as an
 adapter for NSNumber bools that get returned as "on", "true", "1" etc.
 
 If you specify 'mapper', a class that implements CSMapper is used to do
 the transformation by calling transformValue.
 
 If you specify 'type' and 'mapper', the 'type' is applied first before
 the value gets sent to the mapper.
 */
- (void)mapAttributesWithDictionary:(NSDictionary *)aDictionary {
	[self mapAttributesWithDictionary:aDictionary groups:@[]];
}


- (void)mapAttributesWithDictionary:(NSDictionary *)aDictionary groups:(NSArray *)requiredGroups {
    NSString *mappingString = NSStringFromClass([self class]);
    
	NSDictionary *mapping = [[self class] mappingForEntity:mappingString];

	// TODO: Huh?! What is this doing here?
	if ([[mapping allKeys] count] == 0) {
		mappingString = NSStringFromClass([self class]);
		mapping = [[self class] mappingForEntity:mappingString];
	}
    
	id key = nil;
	NSDictionary *propertyMapping = nil;
	id inputValue = nil;
	id outputValue = nil;
	id subValue = nil;
    id arraySubTypeValue = nil;
	Class forcedClass = nil;
	NSString *forcedClassString = nil;
	NSArray *mappingGroups;
	Class mapperClass = nil;
	SEL selector = nil;

	for (NSString *propertyName in mapping) {
		if (![propertyName isEqualToString:CSMappingParentKey]) {
			propertyMapping = [mapping objectForKey:propertyName];

			// Check if this property has all the required mapping groups
			mappingGroups = [propertyMapping objectForKey:CSMappingGroupsKey];
			if (mappingGroups && mappingGroups.count > 0
				&& requiredGroups && requiredGroups.count > 0)
			{
				BOOL containsAllRequiredGroups = YES;
				for (NSString *group in requiredGroups) {
					if (![mappingGroups containsObject:group]) {
						containsAllRequiredGroups = NO;
						break;
					}
				}

				if (!containsAllRequiredGroups) {
					continue;
				}
			}

			forcedClassString = [propertyMapping objectForKey:CSMappingClassKey];
			forcedClass = NSClassFromString(forcedClassString);
			mapperClass = NSClassFromString([propertyMapping objectForKey:CSMappingMapperKey]);
			
			key = [propertyMapping objectForKey:CSMappingKeyKey];
			// If key is array, try the fetch all values for input value
			if ([key isKindOfClass:[NSString class]]) {
				inputValue = [aDictionary valueForKeyPath:key];
				if (inputValue == nil) {
					// Try getting the default.
					inputValue = [propertyMapping objectForKey:CSMappingDefaultKey];
					if (inputValue == nil) {
						continue;
					}
				}
			} else if ([key isKindOfClass:[NSArray class]]) {
				inputValue = [NSMutableArray arrayWithCapacity:[key count]];
				for (id subKey in key) {
					
					if ([subKey isKindOfClass:[NSDictionary class]]) {
						subValue = [aDictionary valueForKeyPath:[subKey valueForKey:CSMappingKeyKey]];
						
						if (subValue == nil) {
							subValue = [subKey valueForKey:CSMappingDefaultKey];
							[inputValue addObject:subValue];
						} else {
							[inputValue addObject:subValue];
						}
					} else {
						subValue = [aDictionary valueForKeyPath:subKey];
						
						if (subValue != nil) {
							[inputValue addObject:subValue];
						}
					}
				}
				
				if ([inputValue count] == 0) {
					continue;
				}
			}
			
			outputValue = inputValue;
			if (forcedClass && ![inputValue isKindOfClass:forcedClass]) {
				selector = NSSelectorFromString([NSString stringWithFormat:@"%@Value", forcedClass]);
				if ([inputValue respondsToSelector:selector]) {
					// Try to use the built in conversion features for known types
					outputValue = objc_msgSend(inputValue, selector);
				} else {
					// Try to map unknown type with same technique.
					id newValue = [[forcedClass alloc] init];
					[newValue mapAttributesWithDictionary:inputValue];
					outputValue = newValue;
				}
			}
            
            //check to see if there is a type for the objects in an array
            arraySubTypeValue =  [propertyMapping objectForKey:CSMappingArraySubTypeKey];
        
            if ([inputValue isKindOfClass:[NSArray class]] && arraySubTypeValue) {
                forcedClassString = arraySubTypeValue;
                forcedClass = NSClassFromString(arraySubTypeValue);
                
                NSMutableArray *newSubObjectArray = [NSMutableArray new];
                
                for (id subobjectDict in inputValue) {
                    id newValue = [[forcedClass alloc] init];
                    [newValue mapAttributesWithDictionary:subobjectDict];
                    [newSubObjectArray addObject:newValue];
                }
                outputValue = newSubObjectArray;
            }

			if (mapperClass && mapperClass) {
				outputValue = [(id<CSMapper>)mapperClass transformValue:inputValue];
			}
			
			[self setValue:outputValue forKey:propertyName];
		}
	}
}


static NSMutableDictionary *mappingCache = NULL;

/**
 Finds the .plist file for an entityKey
 */
+ (NSDictionary *)mappingForEntity:(NSString *)entityKey {
    if (mappingCache == NULL) {
        mappingCache = [[NSMutableDictionary alloc] init];
    }
    
    id cached = [mappingCache objectForKey:entityKey];
    if (cached) {
        return cached;
    }

	// Check for .plist, if it doesn't exist, check for JSON
	NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:entityKey ofType:@"plist"];
	NSDictionary *mapping = nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		mapping = [NSDictionary dictionaryWithContentsOfFile:filePath];
	} else {
		filePath = [[NSBundle bundleForClass:[self class]] pathForResource:entityKey ofType:@"json"];
		mapping = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:0 error:nil];
	}

	NSAssert(mapping != nil, @"Mapping for %@ could not be found", entityKey);
	
	id parentEntityMapping = [mapping objectForKey:CSMappingParentKey];
	NSArray *parents = [NSArray array];
	if ([parentEntityMapping isKindOfClass:[NSArray class]]) {
		parents = parentEntityMapping;
	} else if (parentEntityMapping != nil) {
		parents = [NSArray arrayWithObject:parentEntityMapping];
	}
	
	NSMutableDictionary *mappingResult = [NSMutableDictionary dictionary];
	for (NSString *parent in parents) {
		[mappingResult addEntriesFromDictionary:[[self class] mappingForEntity:parent]];
	}

	[mappingResult addEntriesFromDictionary:mapping];
    [mappingCache setObject:mappingResult forKey:entityKey];
	return mappingResult;
}


/**
 Converts an object into an NSNumber
 */
- (NSNumber *)NSNumberValue {
	if ([self isKindOfClass:[NSString class]]) {
		NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		NSNumber *retval = [f numberFromString:(NSString *)self];
		
		return retval;
	} else if ([self isKindOfClass:[NSNumber class]]) {
		
		return (NSNumber *)self;
	} else {
		
		return nil;
	}
}


/**
 Converts an object into an NSString
 */
- (NSString *)NSStringValue {
	if ([self isKindOfClass:[NSObject class]]) {
		NSString *retval = [NSString stringWithFormat:@"%@", self];
		
		return retval;
	}
	
	return nil;
}


@end

