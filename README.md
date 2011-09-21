# Overview

Use the raw mongo driver in a safer way by using constants for fields and MongoDB operators.
You may want to use the raw driver for speed, but there is another safety benefit:
you understand exactly what is going on in the driver.
Mongoid provides some nice features, but it can only make a best guess at your intent.
Sometimes it is important that you know exactly what the query looks like and what it will look like even after upgrading Mongoid.

I am currently just adding functionality as I need it, but it should be very easy to add anything you need- just send a pull request.

## Constants, not strings.

A constant for each mongoDB operator:

    PULL = "$pull"
    PULL_ALL = "$pullAll"
    PUSH_ALL = "$pushAll"

## Convenience methods that assume Mongoid

A method to make constants out of field names that checks that the fields exist in the Mongoid schema.

``` ruby
    SafeMongoDB.constants_from_mongoid_fields :field1, :field2
    FIELD1 # => :field1
    FIELD2 # => :field2
```

## Usage

``` ruby
class Dog
  include Mongoid::Document
  include SafeMongoDB

  embeds_many :friends
  field :name

  constants_from_mongoid_fields :name, :friends

  def forsake_people
    human_criteria = friends.where(friend_type: Friend::Human)
    update_self PULL => {FRIENDS => human_criteria.selector}
  end
end
```
class Friend
  Human = 0
  Dog = 1
  embedded_in :person

  field :friend_type
  field :name
end
