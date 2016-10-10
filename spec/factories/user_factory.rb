FactoryGirl.define do
  factory :default, class: User do
    email                 'test@test.com'
    password              'test_password'
    password_confirmation 'test_password'
    type                  'Member'
    after(:create) do |u|
      create(:preference, user: u, key: 'key1')
      create(:preference, user: u, key: 'key2')
    end
  end

  factory :member, class: User do
    sequence(:email) { |n| "test#{n}@test.com" }
    password              'test_password'
    password_confirmation 'test_password'
    type                  'Member'
  end

  factory :admin, class: User do
    sequence(:email) { |n| "admin#{n}@test.com" }
    password              'test_password'
    password_confirmation 'test_password'
    type                  'Admin'
  end

  factory :preference, class: Preference do
    key   'key'
    value 'value'
  end
end
