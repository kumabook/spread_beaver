# frozen_string_literal: true
class AddMixDurationToTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :mix_duration, :integer, null: false, default: 3.days.to_i
  end
end
