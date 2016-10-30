class Preference < ApplicationRecord
  belongs_to :user

  DELETE_VALUE = "==DELETE=="
end
