# frozen_string_literal: true

class Preference < ApplicationRecord
  belongs_to :user

  DELETE_VALUE = "==DELETE=="
end
