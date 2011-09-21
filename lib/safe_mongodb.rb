module SafeMongoDB
  PULL_ALL = "$pullAll"
  PUSH_ALL = "$pushAll"
  PULL = "$pull"

  def self.included into
    if into.ancestors.include? ::Mongoid::Document
      into.extend         SafeMongoDB::Mongoid::ClassMethods
      into.send :include, SafeMongoDB::Mongoid::InstanceMethods
    end
  end

  module Mongoid
    module InstanceMethods
      def mongo_self meth, *args
        collection.send(meth, {_id:id}, *args)
      end

      def update_self *args
        mongo_self :update, *args
      end
    end

    module ClassMethods
      def constants_from_mongoid_fields *names
        keys = fields.keys.map(&:to_s)
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
