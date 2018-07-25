# frozen_string_literal: true

module Enclosure
  extend ActiveSupport::Concern
  LEGACY_PROVIDERS = %w[YouTube SoundCloud]
  ENTRIES_LIMIT         = 100
  PARTIAL_ENTRIES_LIMIT = 100
  PICKS_LIMIT           = 9
  CONTAINERS_LIMIT      = 25

  included do
    attr_accessor :engagement
    attr_accessor :partial_entries
    attr_accessor :scores
    attr_accessor :rank
    attr_accessor :previous_rank
    include Streamable
    include Likable
    include Savable
    include Playable
    include EnclosureEngagementScorer

    after_create :purge_all
    after_save :purge
    after_destroy :purge, :purge_all
    after_touch :purge
    after_save :create_identity_mark

    enum provider: %i[Raw Custom YouTube SoundCloud Spotify AppleMusic]

    has_many :entry_enclosures, dependent: :destroy, as: :enclosure
    has_many :entries, -> {
      order("entries.published DESC").limit(ENTRIES_LIMIT)
    }, through: :entry_enclosures

    has_many :containers      , dependent: :destroy, class_name: "Pick", foreign_key: "enclosure_id"
    has_many :pick_containers , -> {
      order("picks.created_at DESC").limit(CONTAINERS_LIMIT)
    }, through: :containers, source: :playlist

    has_many :picks           , dependent: :destroy, foreign_key: "container_id"
    has_many :pick_enclosures , -> {
      order("picks.created_at DESC").limit(PICKS_LIMIT)
    }, through: :picks, source: :track

    has_many :enclosure_issues, dependent: :destroy, as: :enclosure
    has_many :issues          , through: :enclosure_issues

    scope :provider, ->(provider) {
      if provider.present? && [Track, Album, Artist, Playlist].include?(self.class)
        where(provider: provider)
      else
        all
      end
    }
    scope :latest, ->(since) {
      if since.nil?
        order(created_at: :desc)
      else
        where(created_at: since..Float::INFINITY).order(created_at: :desc)
      end
    }

    scope :with_content, -> { eager_load(:entries) }
    scope :with_detail, -> {
      eager_load(:entries)
        .eager_load(:pick_containers)
        .eager_load(:pick_enclosures)
    }

    scope :issue , ->(issue) {
      joins(:enclosure_issues)
        .where(enclosure_issues: { issue: issue })
        .order("enclosure_issues.engagement DESC")
    }
    scope :feed, ->(feed) {
      joins(:entries).where(entries: { feed_id: feed.id })
    }
    scope :keyword, ->(keyword) {
      joins(entries: :keywords).where(keywords: { id: keyword.id })
    }
    scope :tag, ->(tag) {
      joins(entries: :tags).where(tags: { id: tag.id })
    }
    scope :topic, ->(topic) {
      joins(entries: {feed: :topics }).where(topics: { id: topic.id })
    }
    scope :category, ->(category) {
      joins(entries: {feed: { subscriptions: :categories }})
        .where(categories: { id: category.id })
    }
    scope :period, ->(period) {
      where({ table_name.to_sym => { created_at:  period }})
    }
  end

  class_methods do
    def create_items_of(entry, items)
      models = items.map do |i|
        model = find_or_create_by_content(i)
        EntryEnclosure.find_or_create_by(entry_id:           entry.id,
                                         enclosure_id:       model.id) do |e|
          e.enclosure_type = name
          e.enclosure_provider = model.provider
          logger.info("Add new #{name} #{i['id']} to entry #{entry.id} #{i['provider']}")
        end
        i["artists"]&.each do |h|
          a = Artist.find_or_create_by(id: h["id"], name: h["name"], provider: h["provider"])
          EnclosureArtist.find_or_create_by(enclosure_id:   model.id,
                                            enclosure_type: Track.name,
                                            artist_id:      a.id)
        end
        model
      end
      models
    end

    def create_with_pink_spider(params)
      c = PinkSpider.new.public_send("create_#{name.downcase}".to_sym, params)
      find_or_create_by_content(c)
    end

    def search(query, page, per_page)
      where("title ILIKE ?", "%#{query}%").page(page).per(per_page)
    end

    def set_partial_entries(enclosures)
      items = EntryEnclosure.where(enclosure_id: enclosures.pluck(:id))
                            .order("entries.published DESC")
                            .joins(:entry)
                            .limit(PARTIAL_ENTRIES_LIMIT)
                            .preload(:entry)
      enclosures.each do |e|
        e.partial_entries = items.select { |item| item.enclosure_id == e.id }
                                 .map(&:entry)
      end
    end

    def set_marks(user, enclosures)
      liked_hash  = user_liked_hash(user, enclosures)
      saved_hash  = user_saved_hash(user, enclosures)
      played_hash = user_played_hash(user, enclosures)
      enclosures.each do |e|
        e.is_liked  = liked_hash[e]
        e.is_saved  = saved_hash[e]
        e.is_played = played_hash[e]
      end
    end

    def set_previous_ranks(enclosures, previous)
      previous.each_with_index do |val, index|
        item = enclosures.find { |v| v.id == val.id }
        item.previous_rank = index + 1 if item.present?
      end
    end

    def marks_hash_of_user(clazz, user, enclosures)
      marks = clazz.where(user_id:      user.id,
                          enclosure_id: enclosures.pluck(:id))
      enclosures.each_with_object({}) do |e, h|
        h[e] = marks.to_a.select { |l| e.id == l.enclosure_id }.first.present?
      end
    end

    def most_featured_items(stream: nil, query: {}, page: 1, per_page: 10)
      # doesn't support locale, use stream filter instead
      count_hash = query_for_best_items(EntryEnclosure, stream, query.no_locale).feed_count
      Mix.items_from_count_hash(self, count_hash, page: page, per_page: per_page)
    end

    def most_picked_items(stream: nil, query: {}, page: 1, per_page: 10)
      # doesn't support locale, use stream filter instead
      count_hash = query_for_best_items(Pick, stream, query.no_locale).pick_count
      Mix.items_from_count_hash(self, count_hash, page: page, per_page: per_page)
    end

    def query_for_best_items(clazz, stream, query=nil)
      clazz.where(enclosure_type: name)
           .period(query.period)
           .locale(query.locale)
           .stream(stream, self)
           .provider(query.provider, self)
    end

    def identity?
      false
    end
  end

  def has_thumbnail?
    respond_to?(:thumbnail_url) && thumbnail_url.present?
  end

  def update_content(params)
    PinkSpider.new.public_send("update_#{self.class.name.downcase}".to_sym, id, params)
    update!(params)
   end

  def legacy?
    is_a?(Track) &LEGACY_PROVIDERS.include?(provider)
  end

  def web_url
    "https://typica.mu/#{self.class.name.downcase}/#{id}"
  end

  def as_content_json
    hash = as_json
    hash["previous_rank"] = previous_rank
    hash["likesCount"]   = likes_count
    hash["entriesCount"] = entries_count
    hash["pickCount"]    = pick_count if respond_to? :pick_count
    hash.delete("users")
    %i[is_liked is_saved is_played engagement].each do |method|
      v = public_send(method)
      hash[method.to_s] = v if !v.nil?
    end

    if !@partial_entries.nil?
      hash["entries"] = @partial_entries.map(&:as_partial_json)
    end
    hash
  end

  def as_detail_json
    hash = as_content_json
    hash["entries"] = entries.map(&:as_partial_json) if hash["entries"].nil?
    hash
  end

  def to_query
    as_content_json.to_query
  end

  def as_enclosure
    {
      href: "typica://v3/#{self.class.name.downcase.pluralize}/#{id}?#{to_query}",
      type: "application/json",
    }
  end

  def create_identity_mark
    return if ![Track, Album, Artist].include?(self.class)
    return if identity_id.nil? || !saved_change_to_identity_id?
    [LikedEnclosure, SavedEnclosure, PlayedEnclosure, Pick].each do |clazz|
      clazz.where(enclosure_id: id).each do |mark|
        mark_params = {}
        if clazz == Pick
          mark_params = {
            enclosure_id:   identity_id,
            enclosure_type: "#{self.class.name}Identity",
            container_id:   mark.container_id,
            container_type: mark.container_type,
          }
        else
          mark_params = {
            enclosure_id:   identity_id,
            enclosure_type: "#{self.class.name}Identity",
            user_id:        mark.user_id
          }
        end
        clazz.find_or_create_by(mark_params) do |v|
          v.created_at = mark.created_at
          v.updated_at = mark.updated_at
        end
      end
    end
  end
end
