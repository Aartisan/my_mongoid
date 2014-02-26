require "my_mongoid/version"

module MyMongoid

  class MyMongoid::DuplicateFieldError < RuntimeError
  end

  class MyMongoid::UnknownAttributeError < RuntimeError
  end

  def self.models
    @models ||= []
  end

  def self.register_model(klass)
    models.push klass unless models.include?(klass)
  end
end

module MyMongoid::Document
  def self.included(klass)
    klass.module_eval do
      extend ClassMethods
      klass.field :_id, :as => :id
      MyMongoid.register_model(klass)
    end
  end

  attr_reader :attributes
  def initialize(attr)
    raise ArgumentError, "Argument is not Hash" unless attr.is_a?(Hash)
    process_attributes(attr)
  end

  def read_attribute(name)
    attributes[name]
  end

  def write_attribute(name, value)
    attributes[name] = value
  end

  def attributes
    @attributes ||= {}
  end


  def new_record?
    true
  end

  def process_attributes(attr=nil)
    attr.each_pair do |key, value|
      raise MyMongoid::UnknownAttributeError unless respond_to?(key)
      send("#{key}=", value)
    end
  end

  alias_method :attributes=, :process_attributes

  #private
  #def process_attribute(name, value)
    #send("#{name}", value)
  #end
end

module MyMongoid::Document::ClassMethods
  def is_mongoid_model?
    true
  end

  def field(name, options = {})
    name = name.to_s


    @fields ||= {}
    raise MyMongoid::DuplicateFieldError if @fields.has_key?(name)
    @fields[name] = MyMongoid::Field.new(name, options)


    define_method(name) do
      self.attributes[name]
    end

    define_method("#{name}=") do |value|
      self.attributes[name] = value
    end

    if options[:as]
      alias_name = options[:as]
      alias_method alias_name, name
      alias_method "#{alias_name}=", "#{name}="
    end
  end

  def fields
    @fields
  end

  def alias_field(field_name, alias_name)
  end
end

class MyMongoid::Field
  attr_reader :name, :options
  def initialize(name,options)
    @name = name
    @options = options
  end
end
