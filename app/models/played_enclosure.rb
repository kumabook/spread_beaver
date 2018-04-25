# frozen_string_literal: true
class PlayedEnclosure < ApplicationRecord
  include EnclosureMark
  include_stream_scopes

  belongs_to :user
  belongs_to :enclosure, counter_cache: :play_count, touch: true
end
