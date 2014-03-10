//
//  CSAPIMapperTests.m
//  CSMapper
//
//  Created by Marc Ammann on 7/25/12.
//  Copyright (c) 2012 Marc Ammann. All rights reserved.
//

#import "CSAPIMapperTests.h"

@interface TestTestComplexMapper : NSObject <CSMapper>

@end


@implementation TestTestComplexMapper

+ (id)transformValue:(id)inputValue {
	return [NSDate dateWithTimeIntervalSince1970:[inputValue integerValue]];
}

@end


@interface TestTestSubtype : NSObject

@property (nonatomic, strong) NSString *testTrivial;

@end


@implementation TestTestSubtype

@synthesize testTrivial;

@end


@interface TestTestObject : NSObject

@property (nonatomic, strong) NSString *testCompound;
@property (nonatomic, readwrite) NSInteger testCount;
@property (nonatomic, strong) NSString *parentBoth;
@property (nonatomic, strong) NSString *parentOne;
@property (nonatomic, strong) NSString *parentTwo;
@property (nonatomic, strong) NSString *testSimple;
@property (nonatomic, strong) NSNumber *testNumber;
@property (nonatomic, strong) NSString *notExisting;
@property (nonatomic, strong) NSDate *testComplex;
@property (nonatomic, strong) TestTestSubtype *testSubtype;
@property (nonatomic, readwrite) BOOL trueBool;
@property (nonatomic, readwrite) BOOL falseBool;
@property (nonatomic, strong) NSString *subSubValue;
@property (nonatomic, strong) NSArray *subArrayValue;
@end


@implementation TestTestObject
@end


@interface TestJsonMappedObject : NSObject

@property (nonatomic, strong) NSString *aValue;
@property (nonatomic, readwrite) BOOL aBoolValue;

@end


@implementation TestJsonMappedObject
@end


@implementation CSAPIMapperTests

- (void)setUp
{
	[super setUp];
	
}


- (void)tearDown
{
	[super tearDown];
}


- (void)testSimpleAssignment
{
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"Testbar",@"test_simple",
						  nil];
	
	TestTestObject *o = [[TestTestObject alloc] init];
	[o mapAttributesWithDictionary:data];
	
	STAssertEqualObjects(o.testSimple, @"Testbar", @"Data needs to match after setting attributes");
}


- (void)testSimpleAssignmentNotMapped
{
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"Testbar",@"not_existing",
						  nil];
	
	TestTestObject *o = [[TestTestObject alloc] init];
	[o mapAttributesWithDictionary:data];
	
	STAssertNil(o.notExisting, @"Maping doesn't exist for not_existing, notExisting should be nil");
}


- (void)testStringToNumber
{
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"24", @"test_number",
						  nil];
	
	TestTestObject *o = [[TestTestObject alloc] init];
	[o mapAttributesWithDictionary:data];
	
	STAssertEqualObjects(o.testNumber, [NSNumber numberWithDouble:24], @"Type needs to be converted");
}


- (void)testComplex
{
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"24", @"test_complex",
						  nil];
	
	TestTestObject *o = [[TestTestObject alloc] init];
	[o mapAttributesWithDictionary:data];
	
	STAssertEqualObjects(o.testComplex, [NSDate dateWithTimeIntervalSince1970:24], @"Type needs to be converted");
}


- (void)testSubtype
{
	NSDictionary *subdata = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"Trivial", @"test_trivial",
							 nil];
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
						  subdata, @"test_subtype",
						  nil];
	
	TestTestObject *o = [[TestTestObject alloc] init];
	[o mapAttributesWithDictionary:data];
	
	STAssertEqualObjects(o.testSubtype.testTrivial, @"Trivial", @"Type needs to be converted to subtype");
}


- (void)testBool
{	
	TestTestObject *o = [[TestTestObject alloc] init];
	
	[o mapAttributesWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"true",@"true_bool",@"false",@"false_bool",nil]];
	STAssertTrue(o.trueBool, @"'true'");
	STAssertFalse(o.falseBool, @"'false'");
	
	[o mapAttributesWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"on",@"true_bool",@"off",@"false_bool",nil]];
	STAssertTrue(o.trueBool, @"'on'");
	STAssertFalse(o.falseBool, @"'off'");
	
	[o mapAttributesWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"true_bool",@"0",@"false_bool",nil]];
	STAssertTrue(o.trueBool, @"'1'");
	STAssertFalse(o.falseBool, @"'0'");
	
	[o mapAttributesWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"true_bool",[NSNumber numberWithBool:NO],@"false_bool",nil]];
	STAssertTrue(o.trueBool, @"'NSNumber: 1'");
	STAssertFalse(o.falseBool, @"'NSNumber: 0'");
}


- (void)testCompound
{
	TestTestObject *o = [[TestTestObject alloc] init];
	
	[o mapAttributesWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"first",@"part_one",@"last",@"part_two",nil]];
	STAssertEqualObjects(@"first:last", o.testCompound, @"Compound Value");
}


- (void)testMultiInheritance
{
	TestTestObject *o = [[TestTestObject alloc] init];
	
	// Check that ParentTwo has precedence
	[o mapAttributesWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"parent_one",@"parent_one_both",@"parent_two",@"parent_two_both",nil]];
	STAssertEqualObjects(@"parent_two", o.parentBoth, @"ParentTwo has precedence");
	
	[o mapAttributesWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"parent_one",@"parent_one_only",@"parent_two",@"parent_two_only",nil]];
	STAssertEqualObjects(@"parent_one", o.parentOne, @"ParentOne needs to be set");
	STAssertEqualObjects(@"parent_two", o.parentTwo, @"ParentTwo needs to be set");
}


- (void)testCompoundSubtype
{
	TestTestObject *o = [[TestTestObject alloc] init];
	
	[o mapAttributesWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"value", @"subSubValue",nil]];
    STAssertEqualObjects(o.subSubValue, @"value", nil);
	
	[o mapAttributesWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:nil, @"subSubValue",nil]];
	STAssertEqualObjects(o.subSubValue, @"subSubDefaultValue", nil);
}


- (void)testArraySubtype
{
	TestTestObject *o = [[TestTestObject alloc] init];
	[o mapAttributesWithDictionary:@{ @"test_subarray" : @[ @{@"test_trivial" : @"Test1"}, @{@"test_trivial" : @"Test2"}, @{@"test_trivial" : @"Test3"}] }];
    STAssertEqualObjects([[o.subArrayValue objectAtIndex:0] testTrivial], @"Test1", nil);
    STAssertEqualObjects([[o.subArrayValue objectAtIndex:1] testTrivial], @"Test2", nil);
    STAssertEqualObjects([[o.subArrayValue objectAtIndex:2] testTrivial], @"Test3", nil);
}


- (void)testJsonMapping
{
	TestJsonMappedObject *o = [TestJsonMappedObject new];
	[o mapAttributesWithDictionary:@{ @"a_value": @"foobar", @"a_bool_value": @"1" }];
	STAssertEqualObjects(o.aValue, @"foobar", @"Value needs to be foobar");
	STAssertEquals(o.aBoolValue, YES, @"Value needs to be True");
}


- (void)testGroups
{
	TestTestObject *oNone = [TestTestObject new];
	TestTestObject *oA = [TestTestObject new];
	TestTestObject *oB = [TestTestObject new];
	TestTestObject *oC = [TestTestObject new];
	TestTestObject *oAB = [TestTestObject new];

	NSDictionary *data = @{ @"test_simple": @"simple", @"true_bool": @"1", @"test_number": @(10) };

	[oNone mapAttributesWithDictionary:data groups:nil];
	[oA mapAttributesWithDictionary:data groups:@[@"testGroupA"]];
	[oB mapAttributesWithDictionary:data groups:@[@"testGroupB"]];
	[oC mapAttributesWithDictionary:data groups:@[@"testGroupC"]];
	[oAB mapAttributesWithDictionary:data groups:@[@"testGroupA", @"testGroupB"]];

	STAssertEqualObjects(oNone.testSimple, @"simple", @"testSimple has no group, should be set");
	STAssertEqualObjects(oA.testSimple, @"simple", @"testSimple has no group, should be set");
	STAssertEqualObjects(oB.testSimple, @"simple", @"testSimple has no group, should be set");
	STAssertEqualObjects(oC.testSimple, @"simple", @"testSimple has no group, should be set");
	STAssertEqualObjects(oAB.testSimple, @"simple", @"testSimple has no group, should be set");

	STAssertEquals(oNone.trueBool, YES, @"trueBool has groupB, should match to no group");
	STAssertEquals(oA.trueBool, NO, @"trueBool has groupB, should not match to group A");
	STAssertEquals(oB.trueBool, YES, @"trueBool has groupB, should not match to group B");
	STAssertEquals(oC.trueBool, NO, @"trueBool has groupB, should not match to group C");
	STAssertEquals(oAB.trueBool, NO, @"trueBool has groupB, should not match to group A & B");

	STAssertEqualObjects(oNone.testNumber, @(10), @"testNumber has groupA, groupB, should match to no group");
	STAssertEqualObjects(oA.testNumber, @(10), @"testNumber has groupA, groupB, should match to groupA");
	STAssertEqualObjects(oB.testNumber, @(10), @"testNumber has groupA, groupB, should match to groupB");
	STAssertEqualObjects(oC.testNumber, nil, @"testNumber has groupA, groupB, should not match to groupC");
	STAssertEqualObjects(oAB.testNumber, @(10), @"testNumber has groupA, groupB, should match to groupA & groupB");
}


@end
