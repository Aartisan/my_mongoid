require "my_mongoid/version"

module MyMongoid

  def self.models
    @models ||= []
  end

  def self.regiest_models(klass)
    models.push klass unless models.include?(klass)
  end
end

module MyMongoid::Document
  def self.included(klass)
    MyMongoid.regiest_models(klass)
    klass.extend(ClassMethods)
  end

  attr_reader :attributes
  def initialize(attr)
    raise ArgumentError, "Argument is not Hash" unless attr.is_a?(Hash)
    @attributes = attr
    #process_attributes(attr)
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
      #process_attribute(key, value)
      send("#{key}=", value)
    end
  end

  private
  def process_attribute(name, value)
    #responds = respond_to?("#{name}=")
    send("#{name}", value)
  end
end

module MyMongoid::Document::ClassMethods
  def is_mongoid_model?
    true
  end
end

