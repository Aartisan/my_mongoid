require "spec_helper"

describe MyMongoid::Document do
  let(:event_class) do
    Class.new { 
      include MyMongoid::Document
      field :created_at
      field :number
    }
  end

  let(:attributes) {
    {
      "created_at" => Time.parse("2014-02-27"),
      "number" => 1
    }
  }

  let(:event) { event_class.new(attributes) }

  it "is a module" do
    expect(MyMongoid::Document).to be_a(Module)
  end

  it "should add class into MyMongoid.models" do
    expect(MyMongoid.models).to include(event_class)
  end

  describe ".new" do
    it "initialize with attributes" do
      expect(event.attributes).to eq(attributes)
    end

    it "raise ArgumentError when attributes is not a hash" do
      expect { event_class.new("123") }.to raise_error(ArgumentError)
    end

    it "has intialization block" do
      time = Time.parse("2014-02-27")
      new_event = event_class.new(attributes) do |event|
        event.created_at = time
      end

      expect(new_event.created_at).to eq(time)
    end
  end

  describe "#read_attribute" do
    it "reads a attribute" do
      expect(event.read_attribute("number")).to eq(1)
    end
  end

  describe "#write_attribute" do
    it "writes a attribute" do
      event.write_attribute("number", 2)
      expect(event.attributes["number"]).to eq(2)
    end
  end

  describe "#new_record?" do
    it "returns true" do
      expect(event.new_record?).to eq(true)
    end
  end

  describe "#process_attributes" do
    it "raise UnknownAttributeError with unkown attribute" do
      expect {
        event.process_attributes( { "foo" => "bar" } )
      }.to raise_error(MyMongoid::UnknownAttributeError)
    end

    it "raise error with invalid type" do
      event_class.module_eval { field :date, type: Time }
      expect {
        event.process_attributes({ "date" => 12 })
      }.to raise_error(StandardError)
    end

    it "process the default value" do
      event_class.module_eval { field :value, default: 2 }
      expect(event.value).to eq(2)
    end
  end

  describe ".field" do
    before do
      event_class.module_eval { field :foo }
    end

    it "defines setter method" do
      event.write_attribute("foo", "bar")
      expect(event.foo).to eq("bar")
    end

    it "defines getter method" do
      event.foo = "bar"
      expect(event.foo).to eq("bar")
    end

    it "defines alias with as option" do
      event_class.module_eval { field :hello, as: :h }

      event.hello = "hello"
      expect(event.h).to eq("hello")

      event.h = "h"
      expect(event.hello).to eq("h")
    end

    it "add field to fields" do
      expect(event_class.fields.keys).to include("foo")
    end
  end

  describe ".is_mongoid_model?" do
    it "returns true" do
      expect(event_class.is_mongoid_model?).to eq(true)
    end
  end

end
