module SafeMongoDB
  PUSH = "$push"
  POP  = "$pop"
  PULL = "$pull"
  PULL_ALL   = "$pullAll"
  PUSH_ALL   = "$pushAll"
  ADD_TO_SET = "$addToSet"
  INC = "$inc"
  BIT = "$bit"
  SET = "$set"
  UNSET  = "$unset"
  RENAME = "$rename"
  EACH = "$each"

  def self.included into
    if into.ancestors.include? ::Mongoid::Document
      into.extend         SafeMongoDB::Mongoid::ClassMethods
      into.send :include, SafeMongoDB::Mongoid::InstanceMethods
    end
  end

  module Mongoid
    # Warning: these instance methods are actually quite unsafe!
    # It updates a Mongoid object outside of Mongoid
    # Then it calls reload, which will wipe out your existing changes!
    module InstanceMethods
      def mongo_self meth, *args
        collection.send(meth, {_id:id}, *args)
        reload
      end

      def update_self *args
        mongo_self :update, *args
      end
    end

    module ClassMethods
      def mongo_do meth, *args
        collection.send(meth, *args)
      end

      def update_safe selector, doc
        mongo_do :update, selector, doc, :safe => true
      end

      # require mongo 1.4 driver
      def find_and_modify_safe selector, doc
        if r = mongo_do(:find_and_modify, query: selector, update: doc, new:true, safe:true)
          new(r)
        end
      end

      def mongo_save doc, opts = {}
        if doc[:_id] || doc["_id"]
          doc['updated_at'] ||= doc.delete(:updated_at)
          doc['updated_at'] ||= Time.now.utc
        else
          doc['created_at'] ||= doc.delete(:created_at)
          doc['created_at'] ||= Time.now.utc
        end

        mongo_do :save, doc, opts
      end

      def constants_from_mongoid_fields *names
        keys = fields.keys.map(&:to_s) + relations.keys.map(&:to_s)
        names.each do |name|
          n = name.to_s
          unless keys.include? n
            fail "did not find key: #{name} in the Mongoid fields"
          end
          const_set n.upcase, n
        end
      end
    end
  end
end

if Mongoid::VERSION =~ /(^1)|(^2\.[012])/
  module Mongoid
    class Collection
      delegate :find_and_modify, :to => :master
    end

    module Collections
      class Master
        def find_and_modify(*args)
          retry_on_connection_failure do
            collection.find_and_modify(*args)
          end
        end
      end
    end
  end
end
