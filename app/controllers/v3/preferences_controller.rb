# frozen_string_literal: true

class V3::PreferencesController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_preferences, only: [:update]

  def index
    @preferences = Preference.where(user: current_resource_owner)
    preferences = @preferences.map { |p| [p.key, p.value] }
    render json: Hash[preferences], status: 200
  end

  def update
    preferences = current_resource_owner.preferences
    @preferences.each do |key, value|
      pref = preferences.select { |p| p.key == key }.first
      if pref.present?
        if value == Preference::DELETE_VALUE
          pref.destroy
        else
          pref.update value: value
        end
      elsif value != Preference::DELETE_VALUE
        Preference.create key: key, value: value, user: current_resource_owner
      end
    end

    render json: {}, status: 200
  end

  def set_preferences
    @preferences = JSON.parse request.body.read
  end
end
