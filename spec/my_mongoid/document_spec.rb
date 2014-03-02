# spec/my_mongoid/document_spec.rb

describe MyMongoid::Document do
  it "should be a module" do
    expect(MyMongoid::Document).to be_a(Module)
  end

  it "should have a module named ClassMethods" do 
    expect(MyMongoid::Document::ClassMethods).to be_a(Module)
  end

  class Event
    include MyMongoid::Document
  end

  let(:attributes) {
    {"id" => "123", "public" => true}
  }

  let(:event) do
    Event.new(attributes)
  end


  describe ".new" do
    it "should return a mongoid document instance" do
      expect(event.is_mongoid_model?).to eq(true)
    end

  end

  describe "#read_attribute"
  describe "#write_attribute"
  describe "#process_attributes"
  describe "#new_record?"
end
