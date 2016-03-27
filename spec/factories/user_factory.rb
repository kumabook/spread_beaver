FactoryGirl.define do
  factory :default, class: User do
    email                 'test@test.com'
    password              'test_password'
    password_confirmation 'test_password'
    type                  'Member'
  end

  factory :member, class: User do
    sequence(:email) { |n| "test#{n}@test.com" }
    password              'test_password'
    password_confirmation 'test_password'
    type                  'Member'
  end
end
