#(DOCUMENTATION WORK IN PROGRESS)



## Description

In the world of mapping JSON to our data model, the API may change at any time, and CSMapper is the simplest solution to solve this problem. As an extremely lightweight mapping framework, CSMapper provides the flexibility for an ever changing development environment by mapping of KVO compliant objects, to KVO compliant objects via simple plist configuration files. 


## Features

* Extremelty Fast, Flexible, and Lightweight
* Maps KVO compliant objects via plist configuration
* Supports Mapping Inheritance
* Flexible Runtime Transformations
* Compound Property Mappings


# Using CSMapper

##Basic Use

Let's look at a basic example below with a class definition, a JSON response, and a plist mapping file associated with the class.

### Example


__Person.h__

```
@interface Person : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *age;
@end

```
__JSON Response__

```
{
	'person_name': 'nameValue',
	'person_age' : 28
}

```
__Person.plist__

```
<plist version="1.0">
	<key>name</key>
	<dict>
		<key>key</key>
		<string>person_name</string>
	</dict>
	<key>age</key>
	<dict>
		<key>key</key>
		<string>person_age</string>
	</dict>
</plist>

```

Once the response is received it's as easy as the following line of code to map all the values accordingly to the `Person` model class. 

```
Person *newPersonInstance = [[Person alloc] init];
[newPersonInstance mapAttributesFromDictionary:JSONResponse];

```

# Inheritance

While the single mapping is great for simple use cases, inheritance is always something that comes to mind with these kind of things.
CSMapper solves this problem by specifying a special key, called __*\_\_parent\_\_ *__ which is either a String or an Array of Strings.
What this does is, it takes the Parent mapping and applies it before the actual Mapping takes place.


##Single Inheritance

###Example 
__Person.h__

``` 
@interface Person : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *age;
@end
```

__Programmer.h__

```
@interface Programmer : Person
@property (nonatomic, strong) NSString *programmingSkills;
@end

```
__Person.plist__

	
```
<plist version="1.0">
	<key>name</key>
	<dict>
		<key>key</key>
		<string>person_name</string>
	</dict>
	<key>age</key>
	<dict>
		<key>key</key>
		<string>person_age</string>
	</dict>
</plist>
```

__Programmer.plist__

Notice the __\_\_parent\_\___ key definition for the __Person__ class.

```
<plist version="1.0">
	<key>__parent__</key>
		<string>Person</string>
	<key>programmingSkills</key>
	<dict>
		<key>key</key>
		<string>programming_skills</string>
</plist>

```

__Result__

The Programmer object would map the properties as follows:

```
Programmer:
	name -> person_name
	age -> person_age
	programmingSkills -> programming_skills
	
```

##Multiple Inheritance
###Example

Now, if __\_\_parent\_\___ key in the property is an array, multiple inheritance is used.

__Resource.h__

``` 
@interface Resource : NSObject
@property (nonatomic, strong) NSString *name;
@end
```

__Person.h__

```
@interface Person : NSObject
@property (nonatomic, strong) NSNumber *age;
@end

```
__Programmer.h__

```
@interface Programmer : Person
@property (nonatomic, strong) NSString *programmingSkills;
@end

```

__Resource.plist__

```
<plist version="1.0">
	<key>name</key>
	<dict>
		<key>key</key>
		<string>resource_name</string>
	</dict>
</plist>
```

__Person.plist__

```
<plist version="1.0">
	<key>name</key>
	<dict>
		<key>key</key>
		<string>person_name</string>
	</dict>
	<key>age</key>
	<dict>
		<key>key</key>
		<string>person_age</string>
	</dict>
</plist>

```

__Programmer.plist__

```
<plist version="1.0">
	<key>__parent__</key>
	<array>
		<string>Person</string>
		<string>Resource</string>
	</array>
	<key>programmingSkills</key>
	<dict>
		<key>key</key>
		<string>programming_skills</string>
</plist>

```
__Result__

In this case, the order matters in which the parents appear, hence an Array property in the plist, not an unordered Set. Notice in this example that the order of the __\_\_parent\_\___ key mapping contains __Person__ at the first index, then __Resource__ at the second index. Resource takes precedence here which implies that the __name__ property value on the object gets the value of __resource_name__. 

Here comes a tricky part though, internally, both get set. That means, that CSMapper sets the value for __name__ to the JSON value of __person_name__ and then to the value of __resource_name__. If __resource_name__ is not found in the dictionary, the value of __name__ is preserved because nil values don't get set at the moment. This is a short coming of this approach that might change.

So, the mapping for the Programmer object will look like this:

```
Programmer:
	yearsService -> years_service
	name -> person_name # if resource_name does not exists
	name -> resource_name # if resource_name exists, else it will remain the person_name value if it exists
	age -> person_age
	programmingSkills -> programming_skills

```

# Types

By default the CSMapper is capable of detecting and mapping native datatypes such as ```NSString```, ```NSDate```, ```NSNumber```, ```NSDictionary```, and ```NSArray``` without explicit plist configuration on the fly, yet allows the developer to override them explicitely, even newly defined to custom datatypes. Please refer to the __Mappers__ section below in the case a __BOOL__ value is to be mapped.


## Forced Conversion

Sometimes there is reason to store a returned NSNumber value as a string, and CSMapper allows you that flexibility. By defining the __type__ property within the mappings we can override how the object is going to be store in our model. Let's look at a simple example.

### Example

__Person.h__

``` 
@interface Person : NSObject
@property (nonatomic, strong) NSString *age;
@end

```

__JSON Response__

Notice the age property in the JSON is returned as an NSNumber, but we want to store it as an NSString.

```
{
	'person_age' : 28
}

```
__Person.plist__

By defining the __type__ key for the age property to NSString, CSMapper will explicitely converted it while mapping.

```
<plist version="1.0">
	<key>age</key>
	<dict>
		<key>key</key>
		<string>person_age</string>
		<key>type</key>
		<string>NSString</string>
	</dict>
</plist>

```

__Result__

As simple as that, CSMapper will map the results as an NSString to the Person object.


##Custom Types

Sometimes we defined a custom class as a property of a class. And there is a chance that you may receive a JSON response which contains a dictionary for the custom custom object object property defined in your model. CSMapper gives us the flexibility to use __type__ property within the mappings to directly map sub dictionaries to your model class. Let's look at an example

### Example

__ContactInfo.h__

``` 
@interface ContactInfo : NSObject
@property (nonatomic, strong) NSString *phoneNumber;
@end
```

__Person.h__

Notice the __Person__ class contains contactInfo of type __ContactInfo__

```
@interface Person : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) ContactInfo *contactInfo;
@end

```
__JSON Response__

The JSON returned a dictionary name __contact_info__, which should be stored as a __ContactInfo__ class type.

```
{
	'person_name' : 'Bob',
	'contact_info' : 
		{
			'phone_number' : '12345678900'
		}
}

```
__ContactInfo.plist__

```
<plist version="1.0">
	<key>phoneNumber</key>
	<dict>
		<key>key</key>
		<string>phone_number</string>
	</dict>
</plist>
```

__Person.plist__

Observe the __type__ key below for the __contactInfo__ for the __Person__ is set to __ContactInfo__ type.

```
<plist version="1.0">
	<key>name</key>
	<dict>
		<key>key</key>
		<string>person_name</string>
	</dict>
	<key>contactInfo</key>
	<dict>
		<key>key</key>
		<string>contact_info</string>
		<key>type</key>
		<string>ContactInfo</string>
	</dict>
</plist>

```
__Result__

As simple as that, after mapping the attributes, the __Person__ object will have __contactInfo__ set to a mapped object of type __ContactInfo__.

# Mappers

From time to time, classes may need to pre-process, and transform, single, or multiple JSON values into a custom value for storage. There are many usecases for pre-processing:

* Dealing with dates, which can be returned in many different formats from the server
* Setting binary flags on the model object based on string values returned from the server
* Appending multiple string values together based on the responce to preprocessing values displayed, (i.e scrolling table view cell with label text comprised of 3 attributes)


CSMapper gives you the ability to create an class that abides by the ```CSMapper``` protocol to transform, return, and map a value on the fly

## Single Value Transform

Let's look at an example that can be applied to an NSDate with a single value being transformed to a specific format returned form the server.

###Example

__Person.h__

```
@interface Employee : NSObject
@property (nonatomic, strong) NSDate *hireDate;
@end

```
__JSON Response__

```
{
	"hire_date": "2013-11-01T07:20:20-07:00"
}

```
__Employee.plist__

Notice that we use the __mapper__ key to define the object that will be transforming our ```NSDate```

```
<plist version="1.0">
	<key>hireDate</key>
	<dict>
		<key>key</key>
		<string>hire_date</string>
		<key>mapper</key>
		<string>APIDateMapper</string>
	</dict>
</plist>

```

__APIDateMapper.h__

Class conforms to the __CSMapper__ protocol

```
#import <Foundation/Foundation.h>
#import "CSMapper.h"

@interface APIDateMapper : NSObject <CSMapper>
@end

```
__APIDateMapper.m__

This class creates a static instance for a and ```NSDateFormatter``` in memory, and transforms the ```NSDate``` value accordingly, then returns an ```NSDate``` value. This this is handy as a single point of formatting for an  ```NSDate``` returned by the server, which can modified with ease if the response changes.

```
#import "APIDateMapper.h"

@implementation APIDateMapper

static NSDateFormatter *dateFormatter = nil;

+ (id)transformValue:(id)inputValue {
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		
		dateFormatter.locale = enUSPOSIXLocale;
		dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:sszzzz";
	}
	
	NSDate *retval;
	NSError *error;
	[dateFormatter getObjectValue:&retval forString:inputValue range:nil error:&error];
	
	return retval;
}

@end

```

__Result__

In this example, by setting the __mapper__ key in the plist for the __hireDate__, CSMapper will automatically call the __transformValue:__ method, and assign the returned value to the __hireDate__ property of the __Person__ instance.


## Multi Value Transform

From time to time we need to string multiple values together for display purposes or pre-processing for a specific property. By creating a class that abides by the __CSMapper__ protocol we can pass multiple values for a transformation.

###Example

For this example, imagine we are scrolling through a list, and the display data displays name, age, and hire date, in short form, as a single sting. If we were to attempt to create the display text while scrolling, this could cause unneccesary overhead on the device as each value would need to be processed for each cell in the list as it is about to be displayed.

__Person.h__

Notice the __Person__ class contains contactInfo of type __ContactInfo__

```
@interface Person : NSObject
@property (nonatomic, strong) NSString *metaDisplayString;
@end
```

__JSON Response__

```
{
	'person_name': 'nameValue',
	'person_age' : 28,
	"hire_date": "2013-11-01T07:20:20-07:00"
}

```
__Employee.plist__

Notice that we use the __mapper__ key to define an array of objects that will undergo transformation.

```
<plist version="1.0">
	<key>metaDisplayString</key>
	<dict>
		<key>mapper</key>
		<string>APIMetaStringMapper</string>
		<key>key</key>
		<array>
			<dict>
				<key>key</key>
				<string>person_name</string>
			</dict>
			<dict>
				<key>key</key>
				<string>person_age</string>
			</dict>
			<dict>
				<key>key</key>
				<string>ratings</string>
			</dict>
		</array>
	</dict>
</plist>

```

__APIMetaStringMapper.h__

Class conforms to the ```CSMapper``` protocol

```
#import <Foundation/Foundation.h>
#import "CSMapper.h"

@interface APIMetaStringMapper : NSObject <CSMapper>
@end

```
__APIMetaStringMapper.m__

This class receives an array as the __inputValue__. It is key to understand that the order of the __inputValue__ array maps specifically to the order of the keys defined in the plist.

```
#import "APIMetaStringMapper.h"

@implementation APIMetaStringMapper

static NSDateFormatter *dateFormatter = nil;

+ (id)transformValue:(id)inputValue {
	if (dateFormatter == nil) {
		dateFormatter = [NSDateFormatter new];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
	}
	
    NSMutableString *returnString = [[NSMutableString alloc] init];
    NSString *slash = @"    /   ";
    
    for (id object in inputValue) {
        if ([object isEqual:[inputValue lastObject]]) {
            [returnString appendString:[dateFormatter stringFromDate:object]];
        } else {
            [returnString appendString:object];
            [returnString appendString:slash];
        }
    }
    
    return returnString;
}

@end

```

__Result__

As simple as that, will transform the three inputvalues into a single string and assign it to the __metaDisplayString__ property.


## Compound Attributes

From time to time, one may need a compound attribute value. May it be a compound identifier, or whatever the need may be, CSMapper provides a mapper class ```CSJoinMapper``` which allows you to do just that. In the following scenario, let us pretend we need a compount value of the 

###Example

__Person.h__

Notice the __Person__ class contains contactInfo of type __ContactInfo__

```
@interface Person : NSObject
@property (nonatomic, strong) NSString *compoundIdentifier;
@end
```

__JSON Response__

```
{
	'employee_identifier': '123456789',
	'employee_age' : 28
}

```
__Employee.plist__

Notice that we use the __mapper__ key to define an array of objects that will undergo transformation.

```
<plist version="1.0">
	<key>compoundIdentifier</key>
	<dict>
		<key>mapper</key>
		<string>CSJoinMapper</string>
		<key>key</key>
		<array>
			<dict>
				<key>key</key>
				<string>employee_identifier</string>
			</dict>
			<dict>
				<key>key</key>
				<string>employee_age</string>
			</dict>
		</array>
	</dict>
</plist>

```

__Result__

The resulting value for the compoundIdentifier will be "123456789:28"



## Boolean Attributes

As an API developer we generally can run into many different boolean response values, such as __on__, __1__, __true__, or even __TRUE__. When mapping a boolean value for an object, apply the ```CSAPIBoolMapper``` just as you would in the __Single Transform Example__ above