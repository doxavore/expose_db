module ExposeDB
  module Querying
    def all
      filter(nil)
    end

    def filter(query, *values)
      options = {}
      if query
        options[:query] = {q: query}
        options[:query][:values] = values if values
      end

      results = MultiJson.load get("/#{exposed_as}", options)
      results.map { |json| new(json) }
    end

    # Find a record and raise RecordNotFound if it isn't found.
    def find(id)
      find_by_id(id).tap { |result|
        if result.nil?
          raise RecordNotFound, "#{self.class.name}#find with ID #{id.inspect} was not found"
        end
      }
    end

    # Find a record or return nil if it isn't found.
    def find_by_id(id)
      resp = get("/#{exposed_as}/#{id}")
      case resp.response.code.to_i
      when 200
        result = MultiJson.load resp.parsed_response
        new(result)
      when 404
        nil
      else
        raise "#{self.class.name}#try_find with ID #{id.inspect} returned unexpected response: #{resp.inspect}"
      end
    end
  end
end
