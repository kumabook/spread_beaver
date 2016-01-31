class EntryTrack < ActiveRecord::Base
  belongs_to :entry
  belongs_to :track
end
