module Likable
  extend ActiveSupport::Concern
  def self.included(base)
    likes = "#{base.table_name.singularize}_likes".to_sym
    base.has_many likes, dependent: :destroy
    base.has_many :users, through: likes
    base.alias_attribute :likes, likes

    base.scope :popular, ->        { eager_load(:users).order('saved_count DESC') }
    base.scope :liked,   ->  (uid) { eager_load(:users).where(users: { id: uid }) }
    base.extend(ClassMethods)
  end

  module ClassMethods
    def like_class
      "#{table_name.singularize.capitalize}Like".constantize
    end

    def popular_items_within_period(from: nil, to: nil, page: 1, per_page: nil)
      raise ArgumentError, "Parameter must be not nil" if from.nil? || to.nil?
      user_count_hash = self.like_class
                            .where(enclosure_type: self.name)
                            .period(from, to).user_count
      total_count     = user_count_hash.keys.count
      start_index     = [0, page - 1].max * per_page
      end_index       = [total_count - 1, start_index + per_page - 1].min
      sorted_hashes   = user_count_hash.keys.map {|id|
        {
          id:         id,
          user_count: user_count_hash[id]
        }
      }.sort_by { |hash|
        hash[:user_count]
      }.reverse.slice(start_index..end_index)
      items = self.eager_load(:entries)
                  .find(sorted_hashes.map {|h| h[:id] })
      sorted_items = sorted_hashes.map {|h|
        items.select { |t| t.id == h[:id] }.first
      }
      PaginatedArray.new(sorted_items, total_count)
    end
  end
end
