class ExternalRequests
  class ResultSuccess
    def failure?
      false
    end

    def set_page(page)
      @page = page
      self
    end

    def set_data(data)
      @data = data
      self
    end

    attr_reader :page, :data
  end

  class ResultFailure
    def failure?
      true
    end
  end

  def self.result_success(data, page)
    ResultSuccess.new.set_data(data).set_page(page)
  end

  def self.result_failure
    ResultFailure.new
  end

  def self.search_hn(query, page = nil)
    page = 0 if page.presence.nil? # hn indexed pages from 0

    pagination = {
      page: page,
      hitsPerPage: 10
    }

    url_string = "https://hn.algolia.com/api/v1/search?tags=story&" + { query: query }.to_query + "&" + pagination.to_query
    data = URI.parse(url_string).read("User-Agent" => HnSearchNotebook.app_name, "From" => HnSearchNotebook.app_domain)
    data = JSON.parse(data)

    result_success(data, page)
  rescue URI::Error => e
    result_failure
  end
end