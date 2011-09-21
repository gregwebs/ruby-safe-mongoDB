module SafeMongoDB
  PULL_ALL = "$pullAll"
  PUSH_ALL = "$pushAll"
  PULL = "$pull"

  def self.included into
    if into.ancestors.include? Mongoid::Document
      into.extend SafeMongoDB::Mongoid::ClassMethods
    end

    klass_methods = MongoidMethods.dup
    klass_methods.class_variable_set(:@@included_into, into)
    into.extend 
  end

  # low level MongoDB interface
  def mongo_self meth, *args
    collection.send(meth, {_id:id}, *args)
  end

  def update_self *args
    mongo_self :update, *args
  end

  module Mongoid
    module ClassMethods
      def constants_from_mongoid_fields klass, *names
        keys = klass.fields.keys.map(&:to_s)
        names.each do |name|
          unless keys.include? name.to_s
            fail "did not find key: #{name} in the Mongoid fields"
          end
          const_set name.upcase, name
        end
      end
    end
  end
end
