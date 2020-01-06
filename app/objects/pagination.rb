class Pagination
  def set_page(page)
    @page = page
    self
  end

  def set_per_page(per_page)
    @per_page = per_page
    self
  end

  def set_total_count(total_count)
    @total_count = total_count
    self
  end

  def set_page_or_first(page)
    page = 1 if page.presence.nil?
    @page = page.to_i
    self
  end

  attr_reader :page, :per_page, :total_count

  def offset
    @per_page * (@page - 1)
  end

  def has_many_pages?
    @total_count > @per_page
  end

  def has_previous_page?
    @page > 1
  end

  def has_next_page?
    (@per_page * @page) < @total_count 
  end

  def query_with_previous_page(base_query)
    result = base_query.dup
    result << "&"
    result << { page: @page - 1, per_page: @per_page }.to_query
    result
  end

  def query_with_next_page(base_query)
    result = base_query.dup
    result << "&"
    result << { page: @page + 1, per_page: @per_page }.to_query
    result
  end
end