class EntryIssue < ActiveRecord::Base
  belongs_to :entry
  belongs_to :issue, touch: true
end
