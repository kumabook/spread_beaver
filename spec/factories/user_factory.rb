FactoryGirl.define do
  factory :member, class: User do
    email                 'test@test.com'
    password              'test_password'
    password_confirmation 'test_password'
    type                  'Member'
  end
end
