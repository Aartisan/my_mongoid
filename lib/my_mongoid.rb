require "my_mongoid/version"

module MyMongoid
  module Document
    def self.included(klass)
      MyMongoid.regiest_models(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def is_mongoid_model?
        true
      end
    end
  end

  def self.models
    @models ||= []
  end

  def self.regiest_models(klass)
    models.push klass unless models.include?(klass)
  end
end
