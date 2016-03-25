class UserEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry, counter_cache: :saved_count
end
