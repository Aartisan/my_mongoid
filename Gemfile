source 'http://ruby.taobao.org'

# Specify your gem's dependencies in my_mongoid.gemspec
gemspec

group :test do
  gem "rspec", "~> 3.0.0.beta1"

  if ENV["CI"]
    gem "coveralls", require: false
  else
    gem "guard"
    gem "guard-rspec"
    gem "rb-fsevent"
  end
end
