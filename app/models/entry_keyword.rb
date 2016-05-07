class EntryKeyword < ActiveRecord::Base
  belongs_to :entry
  belongs_to :keyword
end
