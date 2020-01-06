require 'open-uri'

class ExternalRequests
  class ResultSuccess
    def failure?
      false
    end

    def set_pagination(pagination)
      @pagination = pagination
      self
    end

    def set_data(data)
      @data = data
      self
    end

    attr_reader :pagination, :data
  end

  class ResultFailure
    def failure?
      true
    end
  end

  def self.result_success(data, pagination)
    ResultSuccess.new.set_data(data).set_pagination(pagination)
  end

  def self.result_failure
    ResultFailure.new
  end

  def self.search_hn(query, page = nil)
    pagination = Pagination.new
    pagination.set_page_or_first(page)
    pagination.set_per_page(10)

    pagination_query = {
      page: pagination.page - 1, # hn indexes pages from 0
      hitsPerPage: pagination.per_page
    }.to_query

    url_string = "https://hn.algolia.com/api/v1/search?tags=story&" + { query: query }.to_query + "&" + pagination_query
    data = URI.parse(url_string).read("User-Agent" => HnSearchNotebook.app_name, "From" => HnSearchNotebook.app_domain)
    data = JSON.parse(data)

    pagination.set_total_count(data["nbHits"])

    result_success(data, pagination)
  rescue URI::Error, SocketError => e
    result_failure
  end
end