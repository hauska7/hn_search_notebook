class Queries
  def self.query(what, options = nil)
    case what
    when "search_queries_statistics"
      query_strings = SearchQuery.distinct.pluck(:query)
      last_day = SearchQuery.where("created_at > ?", 1.day.ago).group(:query).average(:total_hits_count)
      last_week = SearchQuery.where("created_at > ?", 7.days.ago).group(:query).average(:total_hits_count)

      last_day.transform_values! { |average| Converter.convert(average, "float") }
      last_week.transform_values! { |average| Converter.convert(average, "float") }

      result = query_strings.map do |query_string|
        { query_string: query_string,
          last_day_total_hits_average: last_day[query_string],
          last_week_total_hits_average: last_week[query_string]
         }
      end
      result.sort_by! { |item| item[:last_day_total_hits_average] || 0 }
      result
    else fail
    end
  end
end