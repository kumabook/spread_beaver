# frozen_string_literal: true

class MixesController < ApplicationController
  include Pagination
  include StreamsControllable
  before_action :require_admin
  before_action :set_mix_type, only: [:show]
  before_action :set_locale  , only: [:show]
  before_action :set_stream  , only: [:show]
  before_action :set_period  , only: [:show]
  before_action :set_items   , only: [:show]

  def index; end

  def show
    Entry.set_count_of_enclosures(@items)
    if current_user.present?
      Entry.set_marks(current_user, @items)
      Entry.set_marks_of_enclosures(current_user, @items)
    end
  end

  def set_items
    if @stream.present?
      query  = Mix::Query.new(@period,
                              @type,
                              locale:           @locale,
                              entries_per_feed: entries_per_feed)
      @items = @stream.mix_entries(page:          @page,
                                   per_page:      @per_page,
                                   query:         query,
                                   cache_options: { force: true })
    end
  end
end
