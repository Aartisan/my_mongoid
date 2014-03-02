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
    @new_record_status = true
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
    @new_record_status
  end

  def process_attributes(attrs)
    process_default_attr

    attrs.each_pair do |key, value|
      raise MyMongoid::UnknownAttributeError unless respond_to?(key)
      send("#{key}=", value)
    end
  end

  def process_default_attr
    self.class.fields.each do |key, value|
      send("#{key}=", value.options[:default]) if value.options[:default]
    end
  end

  alias_method :attributes=, :process_attributes
end

module MyMongoid::Document::ClassMethods
  def is_mongoid_model?
    true
  end

  def field(name, options = {})
    name = name.to_s

    raise MyMongoid::DuplicateFieldError if fields.has_key?(name)
    fields[name] = MyMongoid::Field.new(name, options)

    self.module_eval do
      define_method(name) do
        self.attributes[name]
      end

      define_method("#{name}=") do |value|
        self.attributes[name] = value
      end

      if options[:as]
        alias_name = options[:as]
        self.module_eval do
          alias_method alias_name, name
          alias_method "#{alias_name}=", "#{name}="
        end
      end
    end
  end

  def fields
    @fields ||= {}
  end
end

class MyMongoid::Field
  attr_reader :name, :options

  def initialize(name,options)
    @name = name.to_s
    @options = options
  end
end
