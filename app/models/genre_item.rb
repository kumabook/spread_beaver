# frozen_string_literal: true

class GenreItem < ApplicationRecord
  belongs_to :genre_item, touch: true, polymorphic: true
  belongs_to :genre
end
