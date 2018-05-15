# frozen_string_literal: true

class Mixes::EnclosuresController < ApplicationController
  include Pagination
  include StreamsControllable

  before_action :require_admin, only: [:show]
  before_action :set_enclosure_class
  before_action :set_mix_type
  before_action :set_locale
  before_action :set_stream
  before_action :set_period
  before_action :set_items

  def show
    return if @items.nil? || @enclosure_class.nil?

    @enclosure_class.set_marks(current_user, @items) if current_user.present?
    @enclosure_class.set_contents(@items)
  end

  def set_items
    if @stream.present?
      query  = Mix::Query.new(@period,
                              @type,
                              locale:           @locale,
                              provider:         @provider,
                              entries_per_feed: entries_per_feed)
      @items = @stream.mix_enclosures(@enclosure_class,
                                      page:          @page,
                                      per_page:      @per_page,
                                      query:         query,
                                      cache_options: { force: true })
    end
  end
end
