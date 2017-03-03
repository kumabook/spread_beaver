class PaginatedArray < Array
  attr_reader(:total_count)
  def initialize(values, total_count)
    super(values)
    @total_count = total_count
  end
end
