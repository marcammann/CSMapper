# Basics

In its simplest form, CSMapper maps values of KVO compliant objects to KVO compliant objects.
That being said, its use case is to map data from (multi dimensional) dictionaries, for example JSON responses, to objects.

Let's look at an example:

JSON:
{
	'random_key': 'value'
}

FancyObject:
 - randomKey: NSString

now the value of random_key needs to get mapped to randomKey. That's exactly what CSMapper does. 
In this particular case, it would look for a plist file called "FancyObject.plist" which would need to contain a mapping like:

<key>randomKey</key>
<dict>
	<key>key</key>
	<string>random_key</string>
</dict>



# Inheritance

While the single mapping is great for simple use cases, inheritance is always something that comes to mind with these kind of things.
CSMapper solves this problem by specifying a special key, called __parent__ which is either a String or an Array of Strings.
What this does is, it takes the Parent mapping and applies it before the actual Mapping takes place.

Let's look at this:

Person:
	my_addiction -> myAddiction
	hair_color -> hairColor

Programmer:
	__parent__: Person
	programming_skills -> programmingSkills

Designer:
	__parent__: Person
	photoshop_skills -> photoshopSkills


Would result in:

Programmer:
	my_addiction -> myAddiction
	hair_color -> hairColor
	programming_skills -> programmingSkills

Easy enough.

Now, if __parent__ is an array, multiple inheritance is used.

Like:

Robot:
	battery_state -> batteryLevel
	iso_weight -> weight

Person:
	blood_type -> isoBloodType
	weight -> weight

Programmer:
	__parent__: Person, Robot
	programming_skills -> programmingSkills


In this case, the order matters in which the parents appear. (Hence the Array, not an unordered Set).
Robot takes precedence here (that means, the "weight" attribute gets the value of "iso_weight").
Here comes a tricky part though. Internally, both get set. That means, that CSMapper sets the value for weight to the value of "weight" and then to the value of "iso_weight".
If "iso_weight" is not found in the dictionary, the value of "weight" is preserved because nil values don't get set right now. This is a short coming of this approach that might change.


So, Programmer looks like this:

Programmer:
	battery_state -> batteryLevel
	iso_weight -> weight # if iso_weight exists
	weight -> weight # if iso_weight doesn't exist but weight does
	blood_type -> isoBloodType
	programming_skills -> programmingSkills


# Types

# Mappers

# Compuond Attributes
