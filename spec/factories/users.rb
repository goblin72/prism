# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :user do
    email "fred.foonly@example.com"
    password "my_password"
    # association :prism, factory: :prism, strategy: :build
  end
end