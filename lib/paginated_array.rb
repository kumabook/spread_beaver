class PaginatedArray < Array
  attr_reader(:total_count, :page, :per_page)
  def initialize(values, total_count, page = 1, per_page = 25)
    super(values)
    @total_count = total_count
    @page        = page
    @per_page    = per_page
  end

  def self.sort_and_paginate_count_hash(count_hash, page: 1, per_page: nil)
    total_count     = count_hash.keys.count
    start_index     = [0, page - 1].max * per_page
    end_index       = [total_count - 1, start_index + per_page - 1].min
    count_hash.keys.map {|id|
      {
        id:    id,
        count: count_hash[id]
      }
    }.sort_by { |hash|
      hash[:count]
    }.reverse.slice(start_index..end_index)
  end

  def total_pages
    (@total_count.to_f / @per_page).ceil
  end

  def current_page
    page
  end

  def limit_value
    per_page
  end
end
