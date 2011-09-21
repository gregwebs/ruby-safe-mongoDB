# Overview

Use the raw mongo driver in a safer way by using constants for fields and MongoDB operators.

MongoDB does not enforce a schema, which is good when you want schemaless.
Most of the time you do actually have a schema in mind, and the ODM (Mongoid) enforces that.
However, sometimes you want to use the raw driver, but still want the safety of an enforced schema- that is what this library tries to provide.

You may want to use the raw driver for speed, but there is another safety benefit to it:
you understand exactly what is going on in the driver.
Mongoid provides some nice features, but it can only make a best guess at your intent when you use its higher level interface. And its lower level interfaces are limited.
Sometimes it is important that you know the query is optimized, and that you can be sure it still will be after you upgrade Mongoid.
This library is designed to work well with Mongoid (and the mongo ruby driver).

I am currently just adding functionality as I need it, but it should be very easy to add anything you need- just send a pull request. I will release this as a gem eventually.

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
```
