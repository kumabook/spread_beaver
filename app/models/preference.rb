class Preference < ActiveRecord::Base
  belongs_to :user

  DELETE_VALUE = "==DELETE=="
end
