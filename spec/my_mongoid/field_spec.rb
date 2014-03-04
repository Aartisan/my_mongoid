# spec/my_mongoid/field_spec.rb
describe MyMongoid::Field do
  it "is a module" do
    expect(MyMongoid::Field).to be_a(Module)
  end

  it "initialize with name and options" do
    field = MyMongoid::Field.new("name", { as: :n })
    expect(field.name).to eq("name")
    expect(field.options).to eq({ as: :n })
  end
end
